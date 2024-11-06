binary_to_japanese = {
    '0000': '日',
    '0001': '手',
    '0010': '目',
    '0011': '口',
    '0100': '木',
    '0101': '竹',
    '0110': '糸',
    '0111': '川',
    '1000': '山',
    '1001': '石',
    '1010': '火',
    '1011': '水',
    '1100': '刀',
    '1101': '土',
    '1110': '空',
    '1111': '月'
}

# create a reversed dictionary: Japanese characters back to binary
japanese_to_binary = {v: k for k, v in binary_to_japanese.items()}

def number_to_japanese(number):
    # Ensure the number is within the range that can fit into 8 bytes (64 bits)
    if number < 0 or number >= 2**64:
        raise ValueError("Number out of range. Please provide a number between 0 and 2^64 - 1.")

    binary_string = f'{number:064b}'
    chunks = [binary_string[i:i+4] for i in range(0, 64, 4)]
    japanese_representation = [binary_to_japanese[chunk] for chunk in chunks]
    
    return ''.join(japanese_representation)

def japanese_to_number(japanese_representation):
    if len(japanese_representation) != 16:
        raise ValueError("Invalid input length. Expected 16 characters for 64 bits.")

    binary_representation = ''.join(japanese_to_binary[char] for char in japanese_representation)
    # convert the binary string back to a number
    return int(binary_representation, 2)

def main():
    number = 1234567890
    japanese_representation = number_to_japanese(number)
    print("Japanese Representation:", japanese_representation)

    # reverse the process
    original_number = japanese_to_number(japanese_representation)
    print("Original Number:", original_number)


if __name__ == "__main__":
    # main()
    st = "日手目口木竹糸川山石火水刀土空月"
    print(bin(japanese_to_number(st)).zfill(64))