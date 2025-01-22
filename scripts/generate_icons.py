from PIL import Image, ImageDraw, ImageFont
import cairosvg
import os

def generate_icons():
    # Ensure static directory exists
    if not os.path.exists('static'):
        os.makedirs('static')

    # Read SVG content
    svg_path = os.path.join('static', 'icon.svg')
    if not os.path.exists(svg_path):
        print(f"Error: {svg_path} not found")
        return

    # Generate icons for different sizes
    sizes = [16, 32, 180, 192, 512]
    for size in sizes:
        # Convert SVG to PNG at the desired size
        png_data = cairosvg.svg2png(
            url=svg_path,
            output_width=size,
            output_height=size
        )

        # Save the icon
        output_path = f'static/icon-{size}.png'
        with open(output_path, 'wb') as f:
            f.write(png_data)

        # Generate favicon.ico from 16x16 version
        if size == 16:
            with open('static/favicon.ico', 'wb') as f:
                f.write(png_data)

        print(f"Generated {output_path}")

if __name__ == '__main__':
    generate_icons() 