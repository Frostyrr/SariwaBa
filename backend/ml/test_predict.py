from predict import predict_image


image_path = (
    r"C:\Users\USER\OneDrive\Desktop\PROjects"
    r"\projectUnknown\backend\datasets\tilapia"
    r"\Fresh\Day 1\Eyes\1_Eyes\0235.jpg"
)


result = predict_image(
    image_path
)

print(result)