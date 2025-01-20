from PIL import Image, ImageDraw, ImageFont
import os

def generate_icons():
    # Ensure static directory exists
    if not os.path.exists('static'):
        os.makedirs('static')

    # Generate icons for different sizes
    sizes = [192, 512]
    for size in sizes:
        # Create a new image with a blue background
        img = Image.new('RGB', (size, size), '#2563eb')
        draw = ImageDraw.Draw(img)

        # Create a larger canvas first
        font_size = int(size * 0.8)  # Use 80% of the icon size
        try:
            font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", font_size)
        except:
            font = ImageFont.load_default()

        text = "W-G"
        # Get the text size
        text_bbox = draw.textbbox((0, 0), text, font=font)
        text_width = text_bbox[2] - text_bbox[0]
        text_height = text_bbox[3] - text_bbox[1]

        # Calculate center position
        x = (size - text_width) // 2
        y = (size - text_height) // 2

        # Draw text at calculated position
        draw.text((x, y), text, font=font, fill="white")

        # Round the corners
        mask = Image.new('L', (size, size), 0)
        mask_draw = ImageDraw.Draw(mask)
        radius = size // 4
        mask_draw.rounded_rectangle([(0, 0), (size-1, size-1)], radius, fill=255)
        
        # Apply the mask
        output = Image.new('RGBA', (size, size), (0, 0, 0, 0))
        output.paste(img, mask=mask)

        # Save the icon
        output_path = f'static/icon-{size}.png'
        output.save(output_path, 'PNG')
        print(f"Generated {output_path}")

if __name__ == '__main__':
    generate_icons() 