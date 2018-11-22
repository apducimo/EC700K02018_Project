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

for line in open (memfile):
  if (lncnt == 0):
    encmemfile.write(line)
    plainmemfile.write(line)
    lncnt = lncnt +1
  else:
    nospcln = line.replace(" ", "").rstrip()
    #print(nospcln)
    #print(len(nospcln))
    if (len(nospcln) == 32):
      plaintext = binascii.unhexlify(nospcln)
    elif (len(nospcln) == 24) :
      plaintext = binascii.unhexlify(nospcln+"13000000")
    elif (len(nospcln) == 16) :
      plaintext = binascii.unhexlify(nospcln+"13000000"+"13000000")
    else:
      plaintext = binascii.unhexlify(nospcln+"13000000"+"13000000"+"13000000")

    plaintext = plaintext[::-1]
    #print(plaintext)
    #print(wrdrevtxt)
    #print(str(binascii.hexlify(plaintext)))
    ciphertext = aes.encrypt(plaintext)
    #print(str(binascii.hexlify(ciphertext).upper()))

    encmemfile.write(str(binascii.hexlify(ciphertext).upper())[26:28])
    encmemfile.write(str(binascii.hexlify(ciphertext).upper())[28:30])
    encmemfile.write(str(binascii.hexlify(ciphertext).upper())[30:32])
    encmemfile.write(str(binascii.hexlify(ciphertext).upper())[32:34]+"\n")

    encmemfile.write(str(binascii.hexlify(ciphertext).upper())[18:20])
    encmemfile.write(str(binascii.hexlify(ciphertext).upper())[20:22])
    encmemfile.write(str(binascii.hexlify(ciphertext).upper())[22:24])
    encmemfile.write(str(binascii.hexlify(ciphertext).upper())[24:26]+"\n")

    encmemfile.write(str(binascii.hexlify(ciphertext).upper())[10:12])
    encmemfile.write(str(binascii.hexlify(ciphertext).upper())[12:14])
    encmemfile.write(str(binascii.hexlify(ciphertext).upper())[14:16])
    encmemfile.write(str(binascii.hexlify(ciphertext).upper())[16:18]+"\n")

    encmemfile.write(str(binascii.hexlify(ciphertext).upper())[2:4])
    encmemfile.write(str(binascii.hexlify(ciphertext).upper())[4:6])
    encmemfile.write(str(binascii.hexlify(ciphertext).upper())[6:8])
    encmemfile.write(str(binascii.hexlify(ciphertext).upper())[8:10]+"\n")

    #plaintext = aes.decrypt(aes.encrypt(plaintext))
    #plainmemfile.write(str(binascii.hexlify(plaintext).upper())[2:4]+" ")
    #plainmemfile.write(str(binascii.hexlify(plaintext).upper())[4:6]+" ")
    #plainmemfile.write(str(binascii.hexlify(plaintext).upper())[6:8]+" ")
    #plainmemfile.write(str(binascii.hexlify(plaintext).upper())[8:10]+" ")
    #plainmemfile.write(str(binascii.hexlify(plaintext).upper())[10:12]+" ")
    #plainmemfile.write(str(binascii.hexlify(plaintext).upper())[12:14]+" ")
    #plainmemfile.write(str(binascii.hexlify(plaintext).upper())[14:16]+" ")
    #plainmemfile.write(str(binascii.hexlify(plaintext).upper())[16:18]+" ")
    #plainmemfile.write(str(binascii.hexlify(plaintext).upper())[18:20]+" ")
    #plainmemfile.write(str(binascii.hexlify(plaintext).upper())[20:22]+" ")
    #plainmemfile.write(str(binascii.hexlify(plaintext).upper())[22:24]+" ")
    #plainmemfile.write(str(binascii.hexlify(plaintext).upper())[24:26]+" ")
    #plainmemfile.write(str(binascii.hexlify(plaintext).upper())[26:28]+" ")
    #plainmemfile.write(str(binascii.hexlify(plaintext).upper())[28:30]+" ")
    #plainmemfile.write(str(binascii.hexlify(plaintext).upper())[30:32]+" ")
    #plainmemfile.write(str(binascii.hexlify(plaintext).upper())[32:34]+" \n")

    lncnt = lncnt +1
