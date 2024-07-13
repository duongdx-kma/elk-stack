# ELK Multiple node:

## I. Install elasticsearch
```
https://www.elastic.co/guide/en/elasticsearch/reference/current/deb.html
```

**step1:**
```
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg

sudo apt-get install apt-transport-https

echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list

```

**step2:**
```
sudo apt-get update && sudo apt-get install elasticsearch
```