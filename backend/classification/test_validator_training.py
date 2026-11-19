import csv
import tempfile
from pathlib import Path
from unittest.mock import patch

from django.test import SimpleTestCase

from ml.train_validator import gate_metrics, select_threshold
from ml.validator_data import audit_partitions


class CalibrationTests(SimpleTestCase):
    def test_threshold_uses_validation_negatives_and_keeps_both_regions(self):
        scores = [[0.95, 0.03, 0.02], [0.02, 0.97, 0.01], [0.8, 0.1, 0.1]]
        threshold, metrics = select_threshold(scores, [0, 1, 2], 0)
        self.assertGreater(threshold, 0.8)
        self.assertEqual(metrics['unsupported_false_accept_rate'], 0)
        self.assertEqual(metrics['supported_correct_accept_rate'], {'eye': 1, 'gill': 1})
        # The held-out set does not influence the selected threshold.
        test = gate_metrics([[0.99, 0.005, 0.005]], [2], threshold)
        self.assertEqual(test['unsupported_false_accept_rate'], 1)

    def test_no_useful_threshold_fails_instead_of_accepting_nothing(self):
        with self.assertRaises(ValueError):
            select_threshold([[0.7, 0.2, 0.1], [0.2, 0.7, 0.1], [0.99, 0.005, 0.005]], [0, 1, 2], 0)


class PartitionAuditTests(SimpleTestCase):
    def audit(self, specimens, contents, statuses=None, groups=None):
        with tempfile.TemporaryDirectory() as directory:
            base = Path(directory)
            records, splits = [], []
            for index, (specimen, content) in enumerate(zip(specimens, contents)):
                path = f'image{index}.jpg'
                (base / path).write_bytes(content)
                records.append({'image_path': path, 'anatomical_label': 'eye'})
                splits.append({'image_path': path, 'specimen_id': specimen,
                    'group_key': groups[index] if groups else f'capture-{index}',
                    'split': ['train', 'val', 'test'][index],
                    'split_status': statuses[index] if statuses else 'verified'})
            for name, rows in [('validator_labels.csv', records), ('splits.csv', splits)]:
                with (base / name).open('w', newline='') as file:
                    writer = csv.DictWriter(file, fieldnames=rows[0].keys())
                    writer.writeheader()
                    writer.writerows(rows)
            with patch('ml.validator_data.BASE_DIR', base):
                return audit_partitions(base)

    def test_reviewed_independent_partitions_pass(self):
        self.assertEqual(self.audit(['a', 'b', 'c'], [b'a', b'b', b'c'])['train']['eye'], 1)

    def test_same_fish_across_days_is_rejected(self):
        with self.assertRaisesRegex(ValueError, 'multiple partitions'):
            self.audit(['fish1', 'fish1', 'fish2'], [b'a', b'b', b'c'])

    def test_same_capture_source_across_partitions_is_rejected(self):
        with self.assertRaisesRegex(ValueError, 'multiple partitions'):
            self.audit(['a', 'b', 'c'], [b'a', b'b', b'c'], groups=['source1', 'source1', 'source2'])

    def test_identical_images_across_partitions_are_rejected(self):
        with self.assertRaisesRegex(ValueError, 'Byte-identical'):
            self.audit(['a', 'b', 'c'], [b'duplicate', b'duplicate', b'c'])

    def test_unreviewed_or_unknown_specimens_are_rejected(self):
        with self.assertRaisesRegex(ValueError, 'Unreviewed'):
            self.audit(['a', 'b', 'c'], [b'a', b'b', b'c'], statuses=['unassigned'] * 3)
        with self.assertRaisesRegex(ValueError, 'specimen ID'):
            self.audit(['', 'b', 'c'], [b'a', b'b', b'c'])
