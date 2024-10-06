# ELK Multiple node:

## I. Install Common package
```
https://www.elastic.co/guide/en/elasticsearch/reference/current/deb.html
```

### step-01: Pre-requisite: install openJDK:
```bash
sudo apt update
sudo apt install openjdk-11-jdk -y
```

### step-02: Import `gpg-key` and `apt-repository`
```bash
# Import the Elasticsearch PGP Key
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg

# Installing from the APT repository
sudo apt-get update
sudo apt-get install apt-transport-https

echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list
```

### step-03: install `elasticsearch`
```bash
sudo apt-get update && sudo apt-get install elasticsearch
```

## II. node01:
### step-01: `Node01`: edit `elasticsearch` configure
```bash
/etc/elasticsearch/elasticsearch.yml
```

### step-02: change owner `/etc/elasticsearch`
```bash
chown -R elasticsearch:elasticsearch /etc/elasticsearch
```

### step-03: start and enable `elasticsearch`:
```bash
systemctl enable elasticsearch;
systemctl daemon-reload;
systemctl start elasticsearch;
```

### step-04: change `elastic` password
```bash
/usr/share/elasticsearch/bin/elasticsearch-reset-password -i -u elastic
```

### step-05: checking elastic `node01`:
```bash
# check cluster health
curl -k -u elastic:elastic https://192.168.61.151:9200/_cluster/health?pretty

{
  "cluster_name" : "es-demo-cluster",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 1,
  "active_shards" : 1,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 100.0
}

# check cluster master
curl -k -u elastic:elastic https://192.168.61.151:9200/_cat/master?pretty

# result
Pd15V6qVTCKBRMv7pZjn8g 10.0.2.15 10.0.2.15 node1

# check cluster nodes
curl -k -u elastic:elastic https://192.168.61.151:9200/_cat/nodes?pretty

# result
10.0.2.15 23 93 1 0.00 0.04 0.05 cdfhilmrstw * node1
```

### step-06: create own `elastic-ca` and `elastic-cert`:
```bash
ES_PROGRAM=/usr/share/elasticsearch/bin/
CERT_DIR=/usr/share/elasticsearch/certs
ETC_CERT_DIR=/etc/elasticsearch/certs

cd $ES_PROGRAM

mkdir cert


# create: `elastic-ca`:
# enter ca-password: 123456
sudo ./elasticsearch-certutil ca \
    --out $CERT_DIR/elastic-stack-ca.p12 \
    --pass 123456

# create: `elastic-certificates.p12`:
# enter ca-password: 123456
# enter cert-password: 123456
# sudo ./elasticsearch-certutil cert \
#     --ca $CERT_DIR/elastic-stack-ca.p12 \
#     --ca-pass 123456 \
#     --out $CERT_DIR/node01-cert.p12 \
#     --name node01 --dns 192.168.61.151 --ip 192.168.61.151 \
#     --pass 123456

# sudo ./elasticsearch-certutil cert \
#     --ca $CERT_DIR/elastic-stack-ca.p12 \
#     --ca-pass 123456 \
#     --out $CERT_DIR/node02-cert.p12 \
#     --name node02 --dns 192.168.61.152 --ip 192.168.61.152 \
#     --pass 123456

sudo ./elasticsearch-certutil cert \
    --ca $CERT_DIR/elastic-stack-ca.p12 \
    --ca-pass 123456 \
    --out $CERT_DIR/common-cert.p12 \
    --pass 123456

# moving certs
cp $CERT_DIR/*.p12 $ETC_CERT_DIR
sudo chown -R root:elasticsearch $ETC_CERT_DIR/*.p12
sudo chmod -R 660 $ETC_CERT_DIR/*.p12

# override password
# xpack.security.transport.ssl.keystore.secure_password
# xpack.security.transport.ssl.truststore.secure_password
# xpack.security.http.ssl.keystore.secure_password

sudo ./elasticsearch-keystore add xpack.security.http.ssl.keystore.secure_password
sudo ./elasticsearch-keystore add xpack.security.transport.ssl.keystore.secure_password
sudo ./elasticsearch-keystore add xpack.security.transport.ssl.truststore.secure_password
```

### step-07: config `HTTP`:
```bash
## Elasticsearch HTTP Certificate Utility

The 'http' command guides you through the process of generating certificates
for use on the HTTP (Rest) interface for Elasticsearch.

This tool will ask you a number of questions in order to generate the right
set of files for your needs.

## Do you wish to generate a Certificate Signing Request (CSR)?

A CSR is used when you want your certificate to be created by an existing
Certificate Authority (CA) that you do not control (that is, you don't have
access to the keys for that CA). 

If you are in a corporate environment with a central security team, then you
may have an existing Corporate CA that can generate your certificate for you.
Infrastructure within your organisation may already be configured to trust this
CA, so it may be easier for clients to connect to Elasticsearch if you use a
CSR and send that request to the team that controls your CA.

If you choose not to generate a CSR, this tool will generate a new certificate
for you. That certificate will be signed by a CA under your control. This is a
quick and easy way to secure your cluster with TLS, but you will need to
configure all your clients to trust that custom CA.

Generate a CSR? [y/N]N

## Do you have an existing Certificate Authority (CA) key-pair that you wish to use to sign your certificate?

If you have an existing CA certificate and key, then you can use that CA to
sign your new http certificate. This allows you to use the same CA across
multiple Elasticsearch clusters which can make it easier to configure clients,
and may be easier for you to manage.

If you do not have an existing CA, one will be generated for you.

Use an existing CA? [y/N]y

## What is the path to your CA?

Please enter the full pathname to the Certificate Authority that you wish to
use for signing your new http certificate. This can be in PKCS#12 (.p12), JKS
(.jks) or PEM (.crt, .key, .pem) format.
CA Path: /etc/elasticsearch/certs/elastic-stack-ca.p12
Reading a PKCS12 keystore requires a password.
It is possible for the keystore's password to be blank,
in which case you can simply press <ENTER> at the prompt
Password for elastic-stack-ca.p12:

## How long should your certificates be valid?

Every certificate has an expiry date. When the expiry date is reached clients
will stop trusting your certificate and TLS connections will fail.

Best practice suggests that you should either:
(a) set this to a short duration (90 - 120 days) and have automatic processes
to generate a new certificate before the old one expires, or
(b) set it to a longer duration (3 - 5 years) and then perform a manual update
a few months before it expires.

You may enter the validity period in years (e.g. 3Y), months (e.g. 18M), or days (e.g. 90D)

For how long should your certificate be valid? [5y] 10y

## Do you wish to generate one certificate per node?

If you have multiple nodes in your cluster, then you may choose to generate a
separate certificate for each of these nodes. Each certificate will have its
own private key, and will be issued for a specific hostname or IP address.

Alternatively, you may wish to generate a single certificate that is valid
across all the hostnames or addresses in your cluster.

If all of your nodes will be accessed through a single domain
(e.g. node01.es.example.com, node02.es.example.com, etc) then you may find it
simpler to generate one certificate with a wildcard hostname (*.es.example.com)
and use that across all of your nodes.

However, if you do not have a common domain name, and you expect to add
additional nodes to your cluster in the future, then you should generate a
certificate per node so that you can more easily generate new certificates when
you provision new nodes.

Generate a certificate per node? [y/N]y

## What is the name of node #1?

This name will be used as part of the certificate file name, and as a
descriptive name within the certificate.

You can use any descriptive name that you like, but we recommend using the name
of the Elasticsearch node.

node #1 name: node01

## Which hostnames will be used to connect to node01?

These hostnames will be added as "DNS" names in the "Subject Alternative Name"
(SAN) field in your certificate.

You should list every hostname and variant that people will use to connect to
your cluster over http.
Do not list IP addresses here, you will be asked to enter them later.

If you wish to use a wildcard certificate (for example *.es.example.com) you
can enter that here.

Enter all the hostnames that you need, one per line.
When you are done, press <ENTER> once more to move on to the next step.

es01

You entered the following hostnames.

 - es01

Is this correct [Y/n]y

## Which IP addresses will be used to connect to node01?

If your clients will ever connect to your nodes by numeric IP address, then you
can list these as valid IP "Subject Alternative Name" (SAN) fields in your
certificate.

If you do not have fixed IP addresses, or not wish to support direct IP access
to your cluster then you can just press <ENTER> to skip this step.

Enter all the IP addresses that you need, one per line.
When you are done, press <ENTER> once more to move on to the next step.

192.168.61.151

You entered the following IP addresses.

 - 192.168.61.151

Is this correct [Y/n]y

## Other certificate options

The generated certificate will have the following additional configuration
values. These values have been selected based on a combination of the
information you have provided above and secure defaults. You should not need to
change these values unless you have specific requirements.

Key Name: node01
Subject DN: CN=node01
Key Size: 2048

Do you wish to change any of these options? [y/N]n
Generate additional certificates? [Y/n]y

## What is the name of node #2?

This name will be used as part of the certificate file name, and as a
descriptive name within the certificate.

You can use any descriptive name that you like, but we recommend using the name
of the Elasticsearch node.

node #2 name: node02

## Which hostnames will be used to connect to node02?

These hostnames will be added as "DNS" names in the "Subject Alternative Name"
(SAN) field in your certificate.

You should list every hostname and variant that people will use to connect to
your cluster over http.
Do not list IP addresses here, you will be asked to enter them later.

If you wish to use a wildcard certificate (for example *.es.example.com) you
can enter that here.

Enter all the hostnames that you need, one per line.
When you are done, press <ENTER> once more to move on to the next step.


You did not enter any hostnames.
Clients are likely to encounter TLS hostname verification errors if they
connect to your cluster using a DNS name.

Is this correct [Y/n]n

Enter all the hostnames that you need, one per line.
When you are done, press <ENTER> once more to move on to the next step.

node02

You entered the following hostnames.

 - node02

Is this correct [Y/n]y

## Which IP addresses will be used to connect to node02?

If your clients will ever connect to your nodes by numeric IP address, then you
can list these as valid IP "Subject Alternative Name" (SAN) fields in your
certificate.

If you do not have fixed IP addresses, or not wish to support direct IP access
to your cluster then you can just press <ENTER> to skip this step.

Enter all the IP addresses that you need, one per line.
When you are done, press <ENTER> once more to move on to the next step.

192.168.61.152

You entered the following IP addresses.

 - 192.168.61.152

Is this correct [Y/n]y

## Other certificate options

The generated certificate will have the following additional configuration
values. These values have been selected based on a combination of the
information you have provided above and secure defaults. You should not need to
change these values unless you have specific requirements.

Key Name: node02
Subject DN: CN=node02
Key Size: 2048

Do you wish to change any of these options? [y/N]n
Generate additional certificates? [Y/n]n

## What password do you want for your private key(s)?

Your private key(s) will be stored in a PKCS#12 keystore file named "http.p12".
This type of keystore is always password protected, but it is possible to use a
blank password.

If you wish to use a blank password, simply press <enter> at the prompt below.
Provide a password for the "http.p12" file:  [<ENTER> for none]
Repeat password to confirm: 

## Where should we save the generated files?

A number of files will be generated including your private key(s),
public certificate(s), and sample configuration options for Elastic Stack products.

These files will be included in a single zip archive.

What filename should be used for the output zip file? [/usr/share/elasticsearch/elasticsearch-ssl-http.zip] 

Zip file written to /usr/share/elasticsearch/elasticsearch-ssl-http.zip
root@es01:/usr/share/elasticsearch# ls
bin  certs  client.pem  elasticsearch-ssl-http.zip  jdk  kibana  lib  modules  NOTICE.txt  plugins  README.asciidoc
root@es01:/usr/share/elasticsearch# unzip elasticsearch-ssl-http.zip 
Archive:  elasticsearch-ssl-http.zip
   creating: elasticsearch/
   creating: elasticsearch/node01/
  inflating: elasticsearch/node01/README.txt  
  inflating: elasticsearch/node01/http.p12  
  inflating: elasticsearch/node01/sample-elasticsearch.yml  
   creating: elasticsearch/node02/
  inflating: elasticsearch/node02/README.txt  
  inflating: elasticsearch/node02/http.p12  
  inflating: elasticsearch/node02/sample-elasticsearch.yml  
replace kibana/README.txt? [y]es, [n]o, [A]ll, [N]one, [r]ename: A
  inflating: kibana/README.txt       
  inflating: kibana/elasticsearch-ca.pem  
  inflating: kibana/sample-kibana.yml  
root@es01:/usr/share/elasticsearch# ls
bin  certs  client.pem  elasticsearch  elasticsearch-ssl-http.zip  jdk  kibana  lib  modules  NOTICE.txt  plugins  README.asciidoc


root@es01:/usr/share/elasticsearch/elasticsearch# tree .
.
├── node01
│   ├── http.p12
│   ├── README.txt
│   └── sample-elasticsearch.yml
└── node02
    ├── http.p12
    ├── README.txt
    └── sample-elasticsearch.yml
```

### step-08: edit config /etc/elasticsearch/elasticsearch.yml
```bash
cp -r /usr/share/elasticsearch/elasticsearch/ /etc/elasticsearch/certs
chown -R root:elasticsearch /etc/elasticsearch/certs
chmod -R 660 /etc/elasticsearch/certs/*/*.p12

# edit config /etc/elasticsearch/elasticsearch.yml
xpack.security.http.ssl:
  enabled: true
  keystore.path: certs/node01/http.p12

xpack.security.transport.ssl.enabled: true
xpack.security.transport.ssl.verification_mode: certificate
xpack.security.transport.ssl.keystore.path: certs/common-cert.p12

xpack.security.transport.ssl.truststore.path: certs/common-cert.p12
```

### step-09: restart `elastic search node01`:
```bash
systemctl restart elasticsearch;
```


### step-10: passing cert to `node02`, `node03`:
```bash
# node 2
scp -i client.pem -r $CERT_DIR deploy@192.168.61.152:/home/deploy

# node 3
scp -i client.pem -r $CERT_DIR deploy@192.168.61.153:/home/deploy
```

### step-10: verify cert:
```bash
openssl pkcs12 -info -in /etc/elasticsearch/certs/elastic-stack-ca.p12 -nodes -passin pass:123456

openssl pkcs12 -info -in /etc/elasticsearch/certs/node01-cert.p12 -nodes -passin pass:123456

openssl pkcs12 -info -in /etc/elasticsearch/certs/node02-cert.p12 -nodes -passin pass:123456
```

## III. node02:

### step-01: moving certs file:
```bash
ETC_CERT_DIR=/etc/elasticsearch/certs

sudo ls -ltra $ETC_CERT_DIR
sudo cp -r certs/* $ETC_CERT_DIR
sudo chown -R root:elasticsearch $ETC_CERT_DIR
sudo chmod -R 660 $ETC_CERT_DIR
```

### step-02: override password:
```bash
sudo ./elasticsearch-keystore add xpack.security.http.ssl.keystore.secure_password
sudo ./elasticsearch-keystore add xpack.security.transport.ssl.keystore.secure_password
sudo ./elasticsearch-keystore add xpack.security.transport.ssl.truststore.secure_password
```

### step-03: edit config /etc/elasticsearch/elasticsearch.yml
```bash
# edit config /etc/elasticsearch/elasticsearch.yml
xpack.security.transport.ssl.enabled: true
xpack.security.transport.ssl.verification_mode: certificate
xpack.security.transport.ssl.keystore.path: certs/node02-cert.p12

xpack.security.transport.ssl.truststore.path: certs/elastic-stack-ca.p12
```

### step-04: restart `elastic search node02`:
```bash
systemctl restart elasticsearch;
```
