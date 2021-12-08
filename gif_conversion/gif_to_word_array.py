"""
    Authored: December 2021
    Author: Kaspar Poland
    Description: Converts a BMP image into an array of words for use in MIPS assembly
"""
import sys
from typing import BinaryIO
from gif_conversion.gif import lzw_decompress, Gif, ImageBlock


def little_endian(bytes_to_add: list[int]):
    """
    Add some number of bytes into a total in a little endian way
    """
    total = 0
    for i, byte in enumerate(bytes_to_add):
        total += (16 ** i) * byte

    return total


def create_color_table(data: bytes):
    """
        Defines the color table the GIF format uses
    """
    table = {}

    start_index = 0xD

    N = data[0xA] % 8
    table_size = 2 ** (N + 1)

    transparency_color_index = data[0xB]

    for i in range(table_size):
        offset = 3 * i + start_index
        if i == transparency_color_index:
            # Based on what is set as transparent in MARS constants section
            decided_color = [0x00, 0xFF, 0xFF, 0xFF]
        else:
            r = data[offset + 0]
            g = data[offset + 1]
            b = data[offset + 2]
            decided_color = [0x00, r, g, b]
        table[i] = decided_color
        table[i].reverse()

    return table


def create_word(number: int):
    """
    Convert an integer into 4 bytes for a word
    """
    return number.to_bytes(4, "little")


def read_data(filepath: str) -> tuple[BinaryIO, bytes]:
    """
        Read the data from a file

        Args:
            filepath (str): The file to read bytes from
        Returns:
            (bytes): the bytes of the file
    """
    try:
        bitmap = open(filepath, "rb")
    except FileNotFoundError:
        print("File didn't exist at filepath: " + filepath)
        sys.exit(1)
    return bitmap, bitmap.read()


def main(input_file_path: str, output_file_path: str):
    """
        Read a GIF and convert to a KMP
    """
    print("Consuming GIF file at: ", input_file_path)
    # Open the file
    input_file, data = read_data(input_file_path)

    # Compute color table
    table = create_color_table(data)

    # Read the GIF file
    gif_file = Gif(input_file_path)

    input_file.close()

    rgb_format = []
    for block in gif_file.blocks:
        if isinstance(block, ImageBlock):
            decompressed_block = block.decompress()
            for color_index in decompressed_block:
                rgb_format.extend(table[color_index])

    # Write GIF data to a different file
    output = open(output_file_path, "wb")
    output.write(bytes(rgb_format))
    output.close()

    print("Saved a new KMP file at: ", output_file_path)


if __name__ == "__main__":
    file_name = f"winScreen"
    in_path = f"assets/gif/screens/{file_name}.gif"
    out_path = f"assets/kmp/screens/{file_name}.kmp"
    main(in_path, out_path)
