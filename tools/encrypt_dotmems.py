from Crypto.Cipher import AES

import binascii

import sys

# Get mem file
memfile = sys.argv[1]

# Create and open output file
encmemfile = open(memfile+".enc", "w+")
plainmemfile = open(memfile+".plain", "w+")

# Set key
key = binascii.unhexlify('00000000000000000000000000000000')

# Create AES object
aes = AES.new(key, AES.MODE_ECB)

lncnt = 0
nospcln = 0

plaintext = ""

for line in open (memfile):
  if "//" in line:
    if not "@" in line:
      plaintext = line.rstrip().split(" ", 1)[0]+plaintext
      lncnt += 1
  if lncnt == 4:
    #encmemfile.write(plaintext)
    plaintext = binascii.unhexlify(plaintext)
    #encmemfile.write("\n")
    ciphertext = aes.encrypt(plaintext)
    encmemfile.write(str(binascii.hexlify(ciphertext).upper())[26:34]+"\n")
    encmemfile.write(str(binascii.hexlify(ciphertext).upper())[18:26]+"\n")
    encmemfile.write(str(binascii.hexlify(ciphertext).upper())[10:18]+"\n")
    encmemfile.write(str(binascii.hexlify(ciphertext).upper())[2:10]+"\n")
    lncnt = 0
    plaintext = ""

while lncnt < 4:
  plaintext="00000013"+plaintext
  lncnt += 1

plaintext = binascii.unhexlify(plaintext)
ciphertext = aes.encrypt(plaintext)
encmemfile.write(str(binascii.hexlify(ciphertext).upper())[26:34]+"\n")
encmemfile.write(str(binascii.hexlify(ciphertext).upper())[18:26]+"\n")
encmemfile.write(str(binascii.hexlify(ciphertext).upper())[10:18]+"\n")
encmemfile.write(str(binascii.hexlify(ciphertext).upper())[2:10]+"\n")
