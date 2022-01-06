# How to extract MINIO generated TLS certificate
   * Run Minio one, it will generate TLS keys using Minikube CA certificate. Get the private key and certificate from kubernetes secrets 
```commandline
kubectl get -n minio-tenant-1 secret/minio-tenant-1-tls --output="jsonpath={.data.private\.key}" | base64 --decode > private.key
kubectl get -n minio-tenant-1 secret/minio-tenant-1-tls --output="jsonpath={.data.public\.crt}" | base64 --decode > public.crt
```

  * [See script](../scripts/get-generated-cert.sh)

# How to generate MINIO TLS certificate 
* https://github.com/minio/minio/tree/master/docs/tls/kubernetes: How to secure access to MinIO on Kubernetes with TLS


```commandline
openssl genrsa -out private.key 2048
openssl req -new -x509 -nodes -days 730 -key private.key -out public.crt -config openssl.conf
```

```commandline
echo -n | openssl s_client -connect minio-tenant-1-console.minio-tenant-1.svc.cluster.local:9443
```
```commandline
cd cert
openssl x509 -in public.crt -noout -text
```

```text
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            07:c5:51:de:60:80:41:cd:1e:a2:62:94:55:a7:8a:69
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: CN=minikubeCA
        Validity
            Not Before: Dec 17 12:35:16 2021 GMT
            Not After : Dec 17 12:35:16 2022 GMT
        Subject: O=system:nodes, CN=system:node:*.minio-tenant-1-hl.minio-tenant-1.svc.cluster.local
        Subject Public Key Info:
            Public Key Algorithm: id-ecPublicKey
                Public-Key: (256 bit)
                pub:
                    04:5a:b3:d2:28:0a:7f:c7:09:0b:55:3d:91:6b:ab:
                    30:ce:76:0e:7e:a5:43:1e:14:3e:6d:bb:42:9b:58:
                    7e:0b:24:2d:19:b6:01:5e:65:90:93:63:ee:45:be:
                    38:e2:f8:93:48:e1:a0:74:d6:22:da:67:42:56:93:
                    1a:08:47:fc:33
                ASN1 OID: prime256v1
                NIST CURVE: P-256
        X509v3 extensions:
            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            X509v3 Extended Key Usage:
                TLS Web Server Authentication, TLS Web Client Authentication
            X509v3 Basic Constraints: critical
                CA:FALSE
            X509v3 Authority Key Identifier:
                keyid:7F:AD:08:47:FE:DF:54:AE:C2:8A:FE:08:86:8F:7E:56:F6:5C:BE:BA

            X509v3 Subject Alternative Name:
                DNS:minio-tenant-1-ss-0-{0...2}.minio-tenant-1-hl.minio-tenant-1.svc.cluster.local, DNS:minio.minio-tenant-1.svc.cluster.local, DNS:minio.minio-tenant-1, DNS:minio.minio-tenant-1.svc, DNS:*.minio-tenant-1-hl.minio-tenant-1.svc.cluster.local, DNS:*.minio-tenant-1.svc.cluster.local
    Signature Algorithm: sha256WithRSAEncryption
         10:fd:c1:09:ae:1a:fc:c1:b2:c1:17:76:ca:b5:3b:65:47:04:
         bb:30:32:28:aa:8f:ea:0c:a6:c7:35:14:df:cd:3a:96:69:aa:
         66:29:56:f2:39:79:3c:56:5b:60:81:ae:c9:6a:01:21:34:66:
         ea:df:77:2a:4d:1f:cd:57:8e:d2:ec:b9:9d:f4:a4:84:92:63:
         3b:fc:94:2f:0a:92:f0:2e:d8:9a:95:c3:19:b5:f1:47:57:3b:
         2c:42:19:11:b9:1e:19:be:98:0c:d5:9b:5c:c5:5b:a1:0c:a0:
         fe:88:9d:28:cf:55:b1:8c:b3:04:95:9d:7d:0c:c0:e4:9f:4f:
         99:9a:bc:80:ab:be:84:67:6a:f8:ef:9f:3e:04:de:0f:6b:5d:
         42:26:e3:ff:77:5b:6d:35:94:32:41:6a:81:01:30:19:0e:90:
         92:33:29:84:34:1f:f8:6c:19:92:27:25:5f:0d:60:c8:2f:9c:
         52:3d:80:55:77:b9:42:c8:58:0c:19:ec:2d:cf:a6:7a:2c:7c:
         42:da:c8:a1:17:4a:52:c5:c4:f1:b0:fb:25:1d:15:6e:6a:ed:
         96:5c:42:65:70:21:37:cb:87:8e:66:16:ec:06:0c:48:fc:08:
         26:11:79:a1:db:a4:b9:ad:ae:ba:e8:4e:7a:b5:a9:1b:62:90:
         5b:e9:69:40
```

# How to add MINIO certificate on Kuberbetes pod, Linux and Java
   * Minikube TLS CA certificate
```commandline
openssl x509 -in $MINIKUBE_HOME/ca.crt -noout -text
```
```text
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number: 1 (0x1)
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: CN=minikubeCA
        Validity
            Not Before: Dec 28 12:33:05 2021 GMT
            Not After : Dec 27 12:33:05 2031 GMT
        Subject: CN=minikubeCA
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
                Modulus:
                    00:bf:bb:8b:5f:16:5a:c0:8b:63:dd:f2:82:b1:22:
                    cc:d5:cb:0f:46:85:f1:ed:12:a4:55:43:4d:36:20:
                    ed:c2:ad:13:33:28:4a:40:b1:1f:84:09:6f:68:57:
                    44:ef:f9:01:9d:df:fa:13:62:7d:6c:db:14:13:3c:
                    0e:76:29:b6:2b:df:fa:14:22:7f:6b:d2:bc:75:88:
                    15:71:9a:c4:73:b1:6b:c6:ab:09:e4:40:0c:9e:a0:
                    ab:18:75:ae:61:bc:78:59:69:a1:97:19:40:38:fa:
                    df:5e:27:00:80:4f:42:1a:d8:a1:cb:a4:bb:4e:fc:
                    3e:83:75:f3:ab:fb:a9:3c:3c:df:87:d7:90:e2:06:
                    5e:cf:67:da:f0:09:08:63:95:1d:8b:d7:76:12:e4:
                    03:5c:15:70:1a:2d:34:3e:0a:a3:99:7a:8c:c2:3e:
                    1d:4d:85:8e:d1:8a:99:10:10:0f:40:61:a0:bb:d3:
                    2e:fa:7c:33:87:0a:39:f1:31:17:b8:e2:5a:e5:ac:
                    73:57:c6:fb:15:22:3d:ea:e2:a3:7f:49:3a:ab:1e:
                    d9:02:a3:8a:a7:bd:9f:94:db:a3:65:75:1a:aa:f6:
                    23:2c:d6:3f:b4:72:03:30:5b:20:83:76:1c:ce:c4:
                    00:8c:85:38:66:2f:05:ec:3a:f8:95:cc:77:ce:ee:
                    53:7b
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment, Certificate Sign
            X509v3 Extended Key Usage:
                TLS Web Client Authentication, TLS Web Server Authentication
            X509v3 Basic Constraints: critical
                CA:TRUE
            X509v3 Subject Key Identifier:
                DC:EB:F5:61:49:7B:C1:5F:83:C9:4C:17:09:94:CC:FA:95:AD:6A:59
    Signature Algorithm: sha256WithRSAEncryption
         2c:c5:fa:f8:3c:db:fa:5d:9b:e8:57:09:17:6f:20:00:1c:49:
         e5:b8:e2:bf:ca:74:fe:87:89:25:0d:31:29:2a:38:82:ff:cd:
         cb:98:bc:b3:81:ee:ea:89:a1:c9:bd:76:0c:25:3e:48:ef:ce:
         ab:66:63:0f:89:83:29:9d:a7:7f:f1:57:cd:b8:ed:d5:df:43:
         18:dc:bb:70:fd:be:49:92:55:0b:57:b6:36:ea:fd:86:52:e5:
         2a:22:1e:43:37:62:49:09:10:29:e5:d0:ee:48:86:ee:8f:61:
         1e:92:79:98:ce:74:3c:b5:48:30:a2:76:ef:d1:52:fe:1b:16:
         1b:00:3a:35:c5:3a:8d:e3:0d:22:2f:76:8a:36:92:48:36:d9:
         da:c6:fe:2d:9e:b7:54:ea:f3:e3:ac:9d:cf:81:f0:10:65:54:
         79:24:24:67:88:86:07:0c:3e:85:fd:2f:f2:0e:87:b8:fe:c7:
         7c:1d:be:93:26:36:7b:c7:9c:0e:da:2d:e3:7a:51:ee:7a:5a:
         84:f9:20:3f:29:74:14:46:60:e0:61:ba:75:cf:87:79:a5:86:
         a0:94:5c:65:aa:c6:4d:f3:cb:1e:1c:c2:ca:8e:41:70:5a:1d:
         f2:bf:a4:ef:5f:bd:6d:42:11:7f:a1:a5:10:41:95:cf:81:dc:
         7a:e8:88:87
```

   * On Kubernetes pod Debian/Ubuntu run:
```commandline
cp $MINIKUBE_HOME/ca.crt /usr/local/share/ca-certificates/
update-ca-certificates
```

## See also
   * https://docs.min.io/minio/k8s/security/security.html#encryption-and-key-management: Encryption and Key Management
      * Search update-ca-certificates
      * "cp /var/run/secrets/kubernetes.io/serviceaccount/ca.crt /usr/local/share/ca-certificates/ ; update-ca-certificates"

# References
   * https://www.ibm.com/docs/en/netcoolomnibus/8?topic=chart-securing-ingress-tls: Securing Ingress with TLS
   * https://www.sslshopper.com/article-most-common-openssl-commands.html: The Most Common OpenSSL Commands
