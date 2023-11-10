# >>>>>>>>>>>>>>>>>> Root Cert <<<<<<<<<<<<<<<<<<<<<<
# ca.key
openssl genrsa -out ca.key 2048

# ca.crt
openssl req -new -key ca.key -x509 -days 3650 -out ca.crt -subj /C=CN/ST=Shaanxi/L="Xi'an"/O=RedHat/CN="Xi'an Redhat Root"

# >>>>>>>>>>>>>>>>>> Server <<<<<<<<<<<<<<<<<<<<<<
# server.key
openssl genrsa -out server.key 2048

# server.csr
openssl req -new -nodes -key server.key -out server.csr -subj /C=CN/ST="Shaanxi"/L="Xi'an"/O="RedHat"/CN="server"

# server.crt
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt

# >>>>>>>>>>>>>>>>>> Client <<<<<<<<<<<<<<<<<<<<<<
# client.key
openssl genrsa -out client.key 2048

# client.csr
openssl req -new -nodes -key client.key -out client.csr -subj /C=CN/ST="Shaanxi"/L="Xi'an"/O="RedHat"/CN="client"

# client.crt
openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out client.crt


# >>>>>>>>>>>>>>>>>> decode the certificate <<<<<<<<<<<<<<<<<<<<<<

# decode CN
openssl x509 -in ca.crt -noout -subject
openssl x509 -in client.crt -noout -subject

# decode other information
openssl x509 -in client.crt -noout -subject -issuer -dates -serial -hash

# >>>>>>>>>>>>>>>>>> validate the certificate with CA <<<<<<<<<<<<<<<<<<<

# -untrusted option specifies any intermediate certificates in the chain. 
# If there are no intermediate certificates, you can omit the -untrusted option.
openssl verify -CAfile ca_root.crt -untrusted intermediate.crt certificate.crt

openssl verify -CAfile ca.crt client.crt


# >>>>>>>>>>>>>>>>>> Verify the Certificate and Key Match <<<<<<<<<<<<<<<<<<<

openssl x509 -noout -modulus -in client.crt | openssl sha256
openssl rsa -noout -modulus -in client.key | openssl sha256

# >>>>>>>>>>>>>>>>>> Encrypt message and Decrypt message <<<<<<<<<<<<<<<<<<<
echo "This is a secret message" > message.txt

# Encrypt the message
openssl rsautl -sign -inkey client.key  -in message.txt -out encrypted_message.bin


# Extract the public key from the certificate
openssl x509 -in client.crt -inform PEM -pubkey -noout > certificate_pubkey.pem

# Decrypt the encrypted message using the extracted public key
openssl rsautl -verify -inkey certificate_pubkey.pem -pubin -in encrypted_message.bin -out decrypted_message.txt

openssl rsautl -verify -inkey certificate_pubkey.pem -pubin -in encrypted_message.bin -out -


