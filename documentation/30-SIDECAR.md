# Generate self signed certificate for local development with SAN

In order to generate a self-signed certificate with Subject Alternative Name (SAN) for local development, you can follow these steps:

1. Generate a private key

OpenSSL `openssl genrsa -out your_private_key.key 2048`. This creates a 2048-bit RSA private key and saves it as your_private_key.key. Replace your_private_key.key with your desired filename.
```bash
openssl genrsa -out your_private_key.key 2048
```

2. Generate a certificate signing request (CSR)

OpenSSL `openssl req -new -key your_private_key.key -out your_csr.csr`. This creates a CSR based on your private key and saves it as your_csr.csr. You will be prompted to enter information about the certificate, such as the country, state, locality, organization, and common name. 
```bash
openssl req -new -key your_private_key.key -out your_csr.csr -subj "/CN=localhost"
```

3. Generate a self-signed certificate with SAN

OpenSSL `openssl x509 -req -days 365 -in your_csr.csr -signkey your_private_key.key -out your_self_signed_certificate.crt`. This command signs the CSR using your private key, creating the self-signed certificate your_self_signed_certificate.crt.

The `-days 365` argument sets the certificate's validity to 365 days. 

```bash
openssl x509 -req -in your_csr.csr -signkey your_private_key.key -out your_certificate.crt -days 365 -extfile <(printf "subjectAltName=DNS:localhost,DNS:example.com") -sha256
```

4. (Optional) Convert to PEM Format
If you need the certificate in PEM format, you can convert it using OpenSSL. The self-signed certificate is already in PEM format, but if you want to ensure it's in the correct format, you can use the following command:
```bash
openssl x509 -in your_self_signed_certificate.crt -out your_self_signed_certificate.pem -outform PEM
```
If you need a .pem file, you can combine the private key and certificate into a single file:
```bash
# Combine private key and certificate into a single PEM file
cat your_private_key.key your_self_signed_certificate.crt > your_certificate.pem.
```
