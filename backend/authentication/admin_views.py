import datetime
import os
import time
from django.contrib.auth.models import User
from django.db import connection, models
from django.utils import timezone
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from classification.models import ClassificationHistory, ClassificationTelemetryLog
from ml.predict import DEVICE, MODEL_PATH, get_model_bundle

from .models import LoginAuditLog, UserProfile
from .permissions import IsAdminRole
from .views import _serialize_user


@api_view(["GET"])
@permission_classes([IsAuthenticated, IsAdminRole])
def admin_stats(request):
    """
    Returns aggregated classification metrics, Fresh vs Not Fresh distributions,
    confidence averages, rejection rates, and inference latency percentiles.
    """
    now = timezone.now()
    twenty_four_hours_ago = now - datetime.timedelta(hours=24)
    seven_days_ago = now - datetime.timedelta(days=7)

    # Classification History Counts
    all_scans = ClassificationHistory.objects.all()
    total_scans = all_scans.count()
    scans_today = all_scans.filter(created_at__gte=twenty_four_hours_ago).count()
    scans_7_days = all_scans.filter(created_at__gte=seven_days_ago).count()

    fresh_count = all_scans.filter(label="Fresh").count()
    not_fresh_count = all_scans.filter(label="Not Fresh").count()
    freshness_rate = round((fresh_count / total_scans * 100), 2) if total_scans > 0 else 0.0

    eye_scans = all_scans.filter(region_type="eye").count()
    gill_scans = all_scans.filter(region_type="gill").count()

    # Confidence metrics
    avg_confidence_data = all_scans.aggregate(avg=models.Avg("confidence"))
    avg_confidence = round(avg_confidence_data["avg"] or 0.0, 4)

    fresh_avg_data = all_scans.filter(label="Fresh").aggregate(avg=models.Avg("confidence"))
    fresh_avg_confidence = round(fresh_avg_data["avg"] or 0.0, 4)

    not_fresh_avg_data = all_scans.filter(label="Not Fresh").aggregate(avg=models.Avg("confidence"))
    not_fresh_avg_confidence = round(not_fresh_avg_data["avg"] or 0.0, 4)

    # Telemetry Log Metrics (Rejection & Latency)
    all_telemetry = ClassificationTelemetryLog.objects.all()
    total_telemetry_requests = all_telemetry.count()

    rejections = all_telemetry.filter(status__startswith="REJECTED_")
    total_rejections = rejections.count()
    rejection_rate = round((total_rejections / total_telemetry_requests * 100), 2) if total_telemetry_requests > 0 else 0.0

    rejections_by_reason = {
        "unsupported_type": all_telemetry.filter(status="REJECTED_UNSUPPORTED_TYPE").count(),
        "dimensions": all_telemetry.filter(status="REJECTED_DIMENSIONS").count(),
        "size": all_telemetry.filter(status="REJECTED_SIZE").count(),
        "corrupted": all_telemetry.filter(status="REJECTED_CORRUPTED").count(),
        "empty": all_telemetry.filter(status="REJECTED_EMPTY").count(),
        "invalid_region": all_telemetry.filter(status="REJECTED_INVALID_REGION").count(),
    }

    errors = all_telemetry.filter(status__startswith="ERROR_")
    total_errors = errors.count()
    error_rate = round((total_errors / total_telemetry_requests * 100), 2) if total_telemetry_requests > 0 else 0.0

    # Latency percentiles
    successful_telemetry = all_telemetry.filter(status="SUCCESS", latency_ms__isnull=False).order_by("latency_ms")
    success_count = successful_telemetry.count()
    if success_count > 0:
        latencies = list(successful_telemetry.values_list("latency_ms", flat=True))
        avg_latency = round(sum(latencies) / len(latencies), 2)
        median_latency = round(latencies[len(latencies) // 2], 2)
        p95_index = min(int(len(latencies) * 0.95), len(latencies) - 1)
        p95_latency = round(latencies[p95_index], 2)
    else:
        avg_latency = 0.0
        median_latency = 0.0
        p95_latency = 0.0

    # Inspector metrics
    total_inspectors = User.objects.count()
    active_inspectors_today = all_scans.filter(
        created_at__gte=twenty_four_hours_ago
    ).values("user").distinct().count()

    return Response({
        "totals": {
            "total_scans": total_scans,
            "scans_today": scans_today,
            "scans_7_days": scans_7_days,
            "total_inspectors": total_inspectors,
            "active_inspectors_today": active_inspectors_today,
        },
        "distribution": {
            "fresh_count": fresh_count,
            "not_fresh_count": not_fresh_count,
            "freshness_rate": freshness_rate,
            "eye_scans": eye_scans,
            "gill_scans": gill_scans,
        },
        "confidence": {
            "average_confidence": avg_confidence,
            "fresh_avg_confidence": fresh_avg_confidence,
            "not_fresh_avg_confidence": not_fresh_avg_confidence,
        },
        "rejection_metrics": {
            "total_requests": total_telemetry_requests,
            "total_rejections": total_rejections,
            "rejection_rate": rejection_rate,
            "rejections_by_reason": rejections_by_reason,
        },
        "error_metrics": {
            "total_errors": total_errors,
            "error_rate": error_rate,
        },
        "latency_metrics": {
            "average_latency_ms": avg_latency,
            "median_latency_ms": median_latency,
            "p95_latency_ms": p95_latency,
        },
    }, status=status.HTTP_200_OK)


@api_view(["GET"])
@permission_classes([IsAuthenticated, IsAdminRole])
def admin_users(request):
    """
    Returns user directory with search, role filter, suspension status, and scan count.
    """
    search_query = request.query_params.get("search", "").strip()
    role_filter = request.query_params.get("role", "").strip()
    suspended_filter = request.query_params.get("is_suspended", "").strip().lower()

    users = User.objects.select_related("profile").annotate(
        scan_count=models.Count("classification_history")
    ).order_by("-date_joined")

    if search_query:
        users = users.filter(
            models.Q(email__icontains=search_query) |
            models.Q(first_name__icontains=search_query) |
            models.Q(last_name__icontains=search_query) |
            models.Q(username__icontains=search_query)
        )

    if role_filter in ["user", "admin"]:
        users = users.filter(profile__role=role_filter)

    if suspended_filter in ["true", "1"]:
        users = users.filter(profile__is_suspended=True)
    elif suspended_filter in ["false", "0"]:
        users = users.filter(profile__is_suspended=False)

    users_list = []
    for u in users:
        p = getattr(u, "profile", None)
        users_list.append({
            "id": u.id,
            "email": u.email,
            "first_name": u.first_name,
            "last_name": u.last_name,
            "username": u.username,
            "profile_picture": p.profile_picture if p else None,
            "role": p.role if p else "user",
            "is_admin": p.is_admin if p else (u.is_staff or u.is_superuser),
            "is_suspended": p.is_suspended if p else False,
            "suspended_at": p.suspended_at.isoformat() if (p and p.suspended_at) else None,
            "scan_count": u.scan_count,
            "created_at": u.date_joined.isoformat(),
        })

    return Response({
        "count": len(users_list),
        "users": users_list,
    }, status=status.HTTP_200_OK)


@api_view(["PATCH"])
@permission_classes([IsAuthenticated, IsAdminRole])
def admin_update_user_role(request, user_id):
    """
    Updates a user's role (admin / user).
    Protects administrators from modifying their own role (self-demotion guard).
    """
    if request.user.id == user_id:
        return Response(
            {
                "error": {
                    "code": "SELF_DEMOTION_PROHIBITED",
                    "message": "Administrators cannot modify their own role.",
                }
            },
            status=status.HTTP_400_BAD_REQUEST,
        )

    new_role = request.data.get("role")
    if new_role not in ["user", "admin"]:
        return Response(
            {
                "error": {
                    "code": "INVALID_ROLE",
                    "message": "Role must be either 'user' or 'admin'.",
                }
            },
            status=status.HTTP_400_BAD_REQUEST,
        )

    target_user = User.objects.filter(id=user_id).select_related("profile").first()
    if not target_user:
        return Response(
            {
                "error": {
                    "code": "USER_NOT_FOUND",
                    "message": "User not found.",
                }
            },
            status=status.HTTP_404_NOT_FOUND,
        )

    profile = target_user.profile
    profile.role = new_role
    profile.save()

    return Response(
        {
            "message": f"User role updated to '{new_role}'.",
            "user": _serialize_user(target_user, profile),
        },
        status=status.HTTP_200_OK,
    )


@api_view(["POST"])
@permission_classes([IsAuthenticated, IsAdminRole])
def admin_toggle_suspension(request, user_id):
    """
    Suspends or reactivates a user account.
    Protects administrators from suspending themselves (self-suspension guard).
    """
    if request.user.id == user_id:
        return Response(
            {
                "error": {
                    "code": "SELF_SUSPENSION_PROHIBITED",
                    "message": "Administrators cannot suspend their own account.",
                }
            },
            status=status.HTTP_400_BAD_REQUEST,
        )

    target_user = User.objects.filter(id=user_id).select_related("profile").first()
    if not target_user:
        return Response(
            {
                "error": {
                    "code": "USER_NOT_FOUND",
                    "message": "User not found.",
                }
            },
            status=status.HTTP_404_NOT_FOUND,
        )

    profile = target_user.profile
    explicit_suspend = request.data.get("is_suspended")
    if explicit_suspend is not None:
        profile.is_suspended = bool(explicit_suspend)
    else:
        profile.is_suspended = not profile.is_suspended

    profile.suspended_at = timezone.now() if profile.is_suspended else None
    profile.save()

    # Append security audit log
    LoginAuditLog.objects.create(
        email=target_user.email,
        ip_address=request.META.get("REMOTE_ADDR"),
        user_agent=request.META.get("HTTP_USER_AGENT", "")[:500],
        status="SUSPENDED_BLOCKED" if profile.is_suspended else "SUCCESS",
        failure_reason=f"Account {'suspended' if profile.is_suspended else 'reactivated'} by admin {request.user.email}",
    )

    return Response(
        {
            "message": f"User {'suspended' if profile.is_suspended else 'reactivated'} successfully.",
            "user": _serialize_user(target_user, profile),
        },
        status=status.HTTP_200_OK,
    )


@api_view(["GET"])
@permission_classes([IsAuthenticated, IsAdminRole])
def admin_security(request):
    """
    Returns security monitoring metrics, failed attempt counts, suspicious pattern alerts,
    and strictly append-only read-only login audit logs.
    """
    now = timezone.now()
    fifteen_mins_ago = now - datetime.timedelta(minutes=15)
    twenty_four_hours_ago = now - datetime.timedelta(hours=24)

    all_logs = LoginAuditLog.objects.all()
    total_attempts = all_logs.count()
    successful_attempts = all_logs.filter(status="SUCCESS").count()
    failed_attempts = all_logs.exclude(status="SUCCESS").count()
    failed_last_24h = all_logs.filter(
        created_at__gte=twenty_four_hours_ago
    ).exclude(status="SUCCESS").count()

    failure_rate = round((failed_attempts / total_attempts * 100), 2) if total_attempts > 0 else 0.0

    # Suspicious pattern detection (>= 3 failures within 15 minutes)
    recent_failures = all_logs.filter(
        created_at__gte=fifteen_mins_ago
    ).exclude(status="SUCCESS")

    suspicious_events = []

    # IP-based clustering
    ip_clusters = recent_failures.values("ip_address").annotate(
        count=models.Count("id")
    ).filter(count__gte=3)

    for item in ip_clusters:
        if item["ip_address"]:
            suspicious_events.append({
                "type": "RAPID_FAILURES_BY_IP",
                "target": item["ip_address"],
                "failure_count": item["count"],
                "window": "15m",
                "severity": "HIGH",
            })

    # Account-based clustering
    account_clusters = recent_failures.exclude(email="").values("email").annotate(
        count=models.Count("id")
    ).filter(count__gte=3)

    for item in account_clusters:
        suspicious_events.append({
            "type": "RAPID_FAILURES_BY_ACCOUNT",
            "target": item["email"],
            "failure_count": item["count"],
            "window": "15m",
            "severity": "HIGH",
        })

    # Suspended account attempts in last 24h
    suspended_attempts = all_logs.filter(
        created_at__gte=twenty_four_hours_ago,
        status="SUSPENDED_BLOCKED"
    ).count()

    if suspended_attempts > 0:
        suspicious_events.append({
            "type": "SUSPENDED_ACCOUNT_LOGIN_ATTEMPTS",
            "target": "Suspended Accounts",
            "failure_count": suspended_attempts,
            "window": "24h",
            "severity": "MEDIUM",
        })

    # Read recent logs (limit 100)
    limit = min(int(request.query_params.get("limit", 50)), 100)
    recent_logs = []
    for log in all_logs[:limit]:
        recent_logs.append({
            "id": log.id,
            "email": log.email,
            "ip_address": log.ip_address,
            "user_agent": log.user_agent,
            "status": log.status,
            "failure_reason": log.failure_reason,
            "created_at": log.created_at.isoformat(),
        })

    return Response({
        "metrics": {
            "total_attempts": total_attempts,
            "successful_attempts": successful_attempts,
            "failed_attempts": failed_attempts,
            "failed_last_24h": failed_last_24h,
            "failure_rate": failure_rate,
            "suspicious_pattern_detected": len(suspicious_events) > 0,
        },
        "suspicious_events": suspicious_events,
        "recent_logs": recent_logs,
    }, status=status.HTTP_200_OK)


@api_view(["GET"])
@permission_classes([IsAuthenticated, IsAdminRole])
def admin_health(request):
    """
    Live system health check: DB ping latency, API throughput summary,
    HTTP status breakdown, and ML model checkpoint/device metadata.
    """
    # 1. Database Connectivity Check
    db_start = time.perf_counter()
    try:
        connection.ensure_connection()
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
            cursor.fetchone()
        db_latency_ms = round((time.perf_counter() - db_start) * 1000, 2)
        db_status = "HEALTHY"
    except Exception as exc:
        db_latency_ms = round((time.perf_counter() - db_start) * 1000, 2)
        db_status = f"DEGRADED: {exc}"

    # 2. ML Model Metadata
    model_file_exists = MODEL_PATH.exists() and MODEL_PATH.is_file()
    model_size_bytes = MODEL_PATH.stat().st_size if model_file_exists else 0
    model_modified_at = (
        datetime.datetime.fromtimestamp(
            MODEL_PATH.stat().st_mtime, tz=datetime.timezone.utc
        ).isoformat()
        if model_file_exists
        else None
    )

    try:
        bundle = get_model_bundle()
        model_ready = True
        model_classes = bundle.get("classes", ["Fresh", "Not Fresh"])
        image_size = bundle.get("image_size", 224)
    except Exception as exc:
        model_ready = False
        model_classes = ["Fresh", "Not Fresh"]
        image_size = 224

    # 3. Telemetry throughput & error rates
    total_telemetry = ClassificationTelemetryLog.objects.count()
    total_success = ClassificationTelemetryLog.objects.filter(status="SUCCESS").count()
    total_client_errors = ClassificationTelemetryLog.objects.filter(status__startswith="REJECTED_").count()
    total_server_errors = ClassificationTelemetryLog.objects.filter(status__startswith="ERROR_").count()

    return Response({
        "database": {
            "status": db_status,
            "latency_ms": db_latency_ms,
            "vendor": connection.vendor,
        },
        "ml_model": {
            "status": "READY" if model_ready else "UNAVAILABLE",
            "architecture": "MobileNetV3-Small",
            "checkpoint_name": MODEL_PATH.name,
            "checkpoint_size_bytes": model_size_bytes,
            "checkpoint_last_modified": model_modified_at,
            "device": str(DEVICE),
            "classes": model_classes,
            "input_resolution": f"{image_size}x{image_size} px",
        },
        "api_throughput": {
            "total_requests_tracked": total_telemetry,
            "success_count": total_success,
            "client_error_count": total_client_errors,
            "server_error_count": total_server_errors,
        },
    }, status=status.HTTP_200_OK)


@api_view(["GET"])
@permission_classes([IsAuthenticated, IsAdminRole])
def admin_audits(request):
    """
    Returns strictly append-only global classification records across all inspectors.
    Protected from administrative deletion (read-only endpoint).
    """
    region_filter = request.query_params.get("region", "").strip().lower()
    label_filter = request.query_params.get("label", "").strip()
    search = request.query_params.get("search", "").strip()

    limit = min(int(request.query_params.get("limit", 50)), 100)
    offset = max(int(request.query_params.get("offset", 0)), 0)

    audits = ClassificationHistory.objects.select_related("user").order_by("-created_at")

    if region_filter in ["eye", "gill"]:
        audits = audits.filter(region_type=region_filter)

    if label_filter in ["Fresh", "Not Fresh"]:
        audits = audits.filter(label=label_filter)

    if search:
        audits = audits.filter(
            models.Q(user__email__icontains=search) |
            models.Q(user__first_name__icontains=search) |
            models.Q(user__last_name__icontains=search)
        )

    total_count = audits.count()
    paginated_audits = audits[offset:offset + limit]

    results = []
    for item in paginated_audits:
        results.append({
            "scan_id": item.scan_id,
            "inspector": {
                "id": item.user.id,
                "email": item.user.email,
                "name": f"{item.user.first_name} {item.user.last_name}".strip() or item.user.username,
            },
            "region_type": item.region_type,
            "label": item.label,
            "confidence": item.confidence,
            "image_url": item.image.url if item.image else None,
            "created_at": item.created_at.isoformat(),
        })

    return Response({
        "total": total_count,
        "offset": offset,
        "limit": limit,
        "results": results,
    }, status=status.HTTP_200_OK)
