HTTPS:n lisääminen nginxiin dockerissa
==========
Tarvitaan SSL/TLS sertifikaatit ja jonkin verran nginx konffin muokkausta.

Snakeoil - kotikutoinen varmenne
-----------

Luodaan julkinen ja yksityinen avain. 509 on standardi. -nodes vivun avulla ei käytetä enkryptausta. Muuten nginx:lle pitää syöttää salasana, jolla se osaa avata salaisen avaimen. 4 kilon avain on suositeltava.

```bash
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -sha256 -days 3650 -nodes
```
Kysyy asiakastietoja sertifikaattiin, jotka ovat vapaa ehtoisia.

Tuottaa:
- cert.pem - julkinen avain, tämän voi lähettää kenelle hyvänsä (public)
- key.pem - salainen avain (private), -nodes-vivutta salasana suojaus, joka kysytään heti alkuun

**Tarkastele avainta**
```bash
openssl x509 -in key.pem -noout -text | less
```

Julkinen sertifikaatti muotoa:
```
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            HEXaa
         Signature Algorithm: ESIM: sha256WithRSAEncryption
                Validity
                    Not Before: Jan 01 12:11:23 2023 GMT
                    Not After: ...
                   ...
           Subject Public Key Info:
 modulO: HEX (long)
 Exponent: int
 ```

Tarkasta, että key ja cert toimivat yhteeb
```bash
openssl x509 -noout -modulus -in certificate.crt | openssl md5
openssl rsa -noout -modulus -in private.key | openssl md5
```


**docker-compose tiedoston muokkaus**
```docker
version: '2'
services:
 kontin_1_nimi_omassa_nimiavaruudessaan:
  image: nginx
  volumes:
   - ${PWD}/ssl:/etc/ssl_host/:ro
  ports: 
   - 80:8080
   - 443:8430
```

Konttiin sisäänmeno
 ```bash
 docker exec -it docker-nginx-1 /bin/sh
 ```
 
 /etc/nginx/conf.d tiedostoon seuraavanlaiset muutokset:
```nginx
# HTTP konfiguraatio: palauta http-kyselyt https:n
server {
	listen 8080;
	return 301 https://$host$request_uri;
}
# HTTPS tarvitsee sertifikaatti konffin
server {
        # Set the port to listen to both in IPv4 and IPv6. Use SSL and HTTP/2.
        listen 8443 ssl http2;     #http2?
        listen [::]:8443 ssl http2; # [::] kaikki ipv6
	
	ssl_certificate /etc/ssl_host/cert.pem
	ssl_certificate_key /etc/ssl_host.pem
	
        # Set the server address.
         #server_name peruna.maa.net; # tässä voitaisiin reitittää
		server_name _; # _ = alaviiva: millä tahansa nimellä pääsee tähän
        # Import self-signed certificates for testing purposes.
        # DO NOT use this in production, please.
      	
	# Proxy paths.
        # Root path.
        # Tämän avulla voidaan reitittää
        location / {
                return 404;
        }
        # Jotkut palvelut halua asua /jotain/ alla, 
        # tällä konfilla saadaan palvelu luulemaan ,että se on juuressa
        #  https://address/jotain/.
        location /jotain/ {
                rewrite ^/jotain/(.*)$ /$1 break; # rstudion mukaan ollaan koko ajan juuressa
                proxy_pass http://localhost:8787;  # kutsutaan palvelua
                proxy_redirect http://localhost:8787/ $scheme://$http_host/jotain/;  # korvaa takaisin /rstudio päätteen,kun lähetään takaisin
                proxy_http_version 1.1; 
                proxy_set_header Upgrade $http_upgrade; # Upgrade avulla voidaan mennä http (tilaton) - protokollasta websocket (tilallinen, kiinteä , ei keksejä) yms.
                proxy_set_header Connection "Upgrade";
        }
}
```
