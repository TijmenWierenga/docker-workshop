
# Docker workshop  
  
## Inhoud  
* Wat zijn containers?  
* Docker Basics  
* Eigen images bouwen  
  
## Wat zijn containers?  
Docker is een container platform. Dus voor we het over Docker hebben is het belangrijker om te definiëren wat containers zijn.  
  
> Put simply, a container consists of an entire runtime environment: an application, plus all its dependencies, libraries and other binaries, and configuration files needed to run it, bundled into one package. - [cio.com](https://www.cio.com/article/2924995/software/what-are-containers-and-why-do-you-need-them.html)  
  
### Wat voor problemen lossen containers op?  
Traditionele setups hebben vaak problemen om alle omgevingen gesynchroniseerd te houden. Voorbeeld: lokaal development met een Vagrant VM met daarop alle benodigde software om je code te draaien en in productie een virtuele machine provisioned door Puppet. Uitdaging: hoe zorg je ervoor dat de Vagrant VM in sync blijft met productie?  
  
Omdat containers alles bundelen tot een pakket wat zowel lokaal als in productie gebruikt kan worden creëer je identieke omgevingen voor alle omgevingen. Wat lokaal werkt, werkt ook in productie, simpelweg omdat het klonen van elkaar zijn. Je deployed dus ook geen code meer, maar het gehele pakket. Dat pakket heet dan een **image**.  
  
Virtual Machines geven technisch gezien dezelfde mogelijkheden, maar er zijn nuance verschillen:  
  
### Vergelijking met  Virtual Machines  
|| Container | Virtual Machines |  
|------|-------------|----------------|  
Virtualisatie | Operating System | Hardware |  
Grootte | Megabytes | Gigabytes |  
Boot time | Snel | Traag |  
Abstractie | App level | Physical hardware |  
  
Architectuur container:  
![Docker container](https://www.docker.com/sites/default/files/Container%402x.png)  
  
Architectuur Virtual Machine:  
![Virtual Machine](https://www.docker.com/sites/default/files/VM%402x.png)  
  
Omdat een Virtual Machine een volledig Guest OS moet klonen is de grootte van een VM significant groter dan de grootte van een container. Docker draait op de Host OS als daemon en draait apps in plaats van operating systems. Dit zorgt voor een bijna instant boot van een app. Docker kan **uitstekend functioneren** op een Virtual Machine voor **optimalisatie** van **server capaciteit**:  
  
![Docker & Virtual Machines](https://www.docker.com/sites/default/files/containers-vms-together.png)  
  
### Security  
* Containers draaien in runtime, dus modificaties van een attacker kunnen ongedaan gemaakt worden door de containers regelmatig te herstarten. In een VM zijn deze wijzigingen vaak persistent en blijft de app besmet door de aanvaller.  
* Als iemand slaagt om in te breken tot een container, is de container de enige plaats waar een aanvaller iets kan doen. Omdat dit een volledig geïsoleerd proces is kan een aanvaller echter weinig/geen schade toebrengen buiten de container.  
* Een security lek in de host kernel kan echter wel geëxploiteerd worden in praktisch elke container die op die host kernel draait.  
  
Docker biedt nog veel meer opties om containers veiliger te maken, maar dat valt buiten de scope van deze introductie.  
  
### Docker  
Docker is een platform die het uitrollen en managen van containers faciliteert.  
  
### XS4ALL  
* Subtiele verschillen per machine  
* Pets versus cattle (verifiëren)  
* Veel services die allemaal een eigen platform nodig hebben  
* Jenkins build slaves voor al deze services  
* Grote afhankelijkheid op het deploy proces van beheer (waar ik mee te maken heb gehad):  
   * Aanvragen van nieuwe services  
   * Installeren van extra software  
   * Inrichten van build slaves  
   * Debuggen van productie fouten  
   * Instellen van environment variables  
  
## Docker Basics  
* Runnen van een image  
* Het maken van een eigen image (Dockerfile)  
* Environment variables  
* Volumes  
   * Voorbeeld van een volume  
   * Waarom je geen volumes mount in productie (pets versus cattle)  
* Ports  
* Dependency management  
* Optimaliseren van een Dockerfile  
* Docker-compose voor service orchestration  
   * Services definiëren  
   * Services koppelen via een netwerk  
* Docker Swarm  
  
### Docker Pull  
Download een image uit een registry (normaal gesproken Docker Hub)  
``` sh  
docker pull hello-world  
```  
Zonder een specifieke versie te noemen download Docker altijd de meest recente versie (latest).  
Door een `colon` toe te voegen als postfix kun je een specifieke versie downloaden. In onderstaande situatie downloaden we Apache versie 2.4.* (images volgen semver).  
  
``` sh  
docker pull httpd:2.4  
```  
  
### Docker Run  
Runt een image als een container:  
``` sh  
docker run hello-world  
```  
  
### Docker PS  
De Docker CLI heeft het grootste deel van zijn functionaliteit dezelfde namen gegeven als de Linux kernel. `docker ps` laat dus zien welke huidige processen (containers dus) er draaien binnen Docker.  
  
Niet alle processen zijn long-running en daarom is het resultaat op dit moment ook dat er geen huidige container draaien op de Docker kernel.  
  
Om alle (ook gestopte) containers te zien moeten we specifieker zijn in wat we als output willen. Met `docker ps --help` kunnen we de opties van `ps` bekijken:  
``` sh  
Usage:  docker ps [OPTIONS]  
  
List containers  
  
Options:  
  -a, --all             Show all containers (default shows just running)  
  -f, --filter filter   Filter output based on conditions provided  
      --format string   Pretty-print containers using a Go template  
  -n, --last int        Show n last created containers (includes all states) (default -1)  
  -l, --latest          Show the latest created container (includes all states)  
      --no-trunc        Don't truncate output  
  -q, --quiet           Only display numeric IDs  
  -s, --size            Display total file sizes  
```   
  
Dus nu we specifieker zijn kunnen we zien dat onze container gestopt is:  
``` sh  
$ docker ps --all  
  
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                      PORTS               NAMES  
47d65b683dc1        hello-world         "/hello"            11 minutes ago      Exited (0) 11 minutes ago                       happy_feynman  
```  
  
### Docker Kill (2)  
Nu we weten hoe we Docker containers moeten starten willen we ze ook kunnen stoppen.  
Laten we eerst een nieuwe container starten. Dit keer gaan we een Apache container starten om een statische web applicatie te draaien:  
  
``` sh  
$ docker run httpd:2.4  
AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 172.17.0.2. Set the 'ServerName' directive globally to suppress this message  
AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 172.17.0.2. Set the 'ServerName' directive globally to suppress this message  
[Fri Jul 13 12:22:39.610091 2018] [mpm_event:notice] [pid 1:tid 140471219697536] AH00489: Apache/2.4.33 (Unix) configured -- resuming normal operations  
[Fri Jul 13 12:22:39.610475 2018] [core:notice] [pid 1:tid 140471219697536] AH00094: Command line: 'httpd -D FOREGROUND'  
```  
  
Apache is een long-running process. Omdat Docker als default containers in de voorgrond uitvoert, blijft het proces zichtbaar in je terminal. Om het proces te stoppen, druk op `ctrl+c`.  
  
Om de container in de achtergrond te starten kunnen we gebruik maken de `deamonized` optie:  
  
``` sh  
$ docker run -d httpd:2.4  
7102713e6f4d7ec3b27a464a4551825b91781d57e1f11eee89bca05f92edb6e5  
```  
De output is de identifier van de container.  
  
Om te verifiëren dat de container draait runnen we nogmaals `docker ps`:  
``` sh  
CONTAINER ID        IMAGE               COMMAND              CREATED              STATUS              PORTS               NAMES  
7102713e6f4d        httpd:2.4           "httpd-foreground"   About a minute ago   Up About a minute   80/tcp              affectionate_clarke  
```  
  
Toch is de container niet bereikbaar voor verkeer omdat we geen port hebben gemapped:  
``` sh  
curl localhost  
curl: (7) Failed to connect to localhost port 80: Connection refused  
```  
  
We zullen de container dus opnieuw moeten starten met de juiste port mapping. Zolang port 80 niet open staat kan de container niet communiceren met de buitenwereld. Dit introduceert dus automatisch een veiligheidsrisico. Alles wat we naar buiten openstellen kan potentieel worden gehackt. Dus wees altijd kritisch wanneer je poorten open zet.  
  
Stop de container met:  
``` sh  
docker stop 7102713e6f4d  
```  
  
Herstart de container vervolgens met de juiste configuratie:  
``` sh  
docker run -d -p 80:80 --name apache httpd:2.4  
```  
  
En verifieer dat Apache draait:  
``` sh  
$ curl localhost  
<html><body><h1>It works!</h1></body></html>  
```  
  
Nu we de container een naam hebben gegeven, kunnen we in plaats van de identifier ook de naam gebruiken om acties uit te voeren op de container:  
``` sh  
docker stop apache  
```  
  
Een gestopte container kan ook weer worden herstart:  
``` sh  
docker start apache  
```  
``` sh  
$ curl localhost  
<html><body><h1>It works!</h1></body></html>  
```  
Als je een kill signal wilt sturen om de container niet 'gracefully' te stoppen, gebruik dan `docker kill`:  
``` sh  
docker kill apache  
```  
  
### Docker RM  
Tijdens deze workshop hebben we al een aantal Docker containers gestart en gestopt. Ondanks dat al onze containers zijn gestopt staan ze nog wel in het geheugen. Om een container te verwijderen kunnen we het volgende doen:  
``` sh  
docker rm apache  
```  
  
### Docker volumes  
Om bestanden van je file system in de container te krijgen kunnen we gebruik maken van volume mounts.  
  
``` sh  
echo "<h1>XS4ALL</h1>" >> index.html  
```  
  
``` sh  
docker run -dit --name apache -p 80:80 -v $(pwd)/index.html:/usr/local/apache2/htdocs/index.html httpd:2.4  
```  
  
Volume mounts zijn zeer geschikt voor development. Iedere wijziging in zowel de container als op je lokale filesystem wordt op beide plaatsen gesynced.  
  
``` sh  
echo "<p>Welkom bij de Docker workshop</p>" >> index.html  
```  
  
Zoals je ziet is de paragraaf direct toegevoegd aan de container.  
  
Een ander voordeel van volume mounts is dat je wijzigingen behouden blijven als je container sterft. Laten we dat simuleren door de container te killen:  
  
``` sh  
docker kill apache && docker rm apache  
```  
  
Als we de container vervolgens weer starten zul je zien dat al onze wijzigingen nog intact zijn. Dit is gelijk ook een nadeel van volume mounts. Zoals eerder besproken is de kracht van containers portability en immutability. Zodra je volume mount integreert in een container is deze afhankelijk geworden van het lokale filesystem. Dit is meestal geen probleem voor development, waar je vrijwel altijd op hetzelfde filesystem werkt van je eigen computer. In productie is dit echter problematisch. Wanneer een node sterft gaat ook alle data behorende tot het filesystem van deze node verloren. Als de applicatie afhankelijk is van de staat van deze data gaat dat ten koste van de portability en immutability. De waarheid is echter dat al onze applicaties afhankelijk zijn van data. Er bestaan een hoop oplossingen om data te managen in een cluster, maar ook kiezen veel engineers ervoor om hun data buiten het cluster te managen.  
  
![Docker shared file storage](https://docs.docker.com/storage/images/volumes-shared-storage.svg)  
  
### Docker exec  
Soms wil je in een draaiende container operaties uitvoeren. Dit kan met `docker exec`. Laten we nog een paragraaf toevoegen aan onze statische web applicatie:  
  
``` sh  
$ docker exec -it apache sh  
# echo "<p>Another one!</p>" >> /usr/local/apache2/htdocs/index.html  
```  
  
## Images  
Tot nu toe hebben we gewerkt met bestaande images, maar om een eigen applicatie te maken die je kunt deployen hebben we een eigen image nodig. Eigen images kun je in Docker maken door een base image te extenden.  
  
### Dockerfile  
Je eigen image definiëer je door layers toe te voegen aan een base image.  
  
``` sh  
FROM php:7.2-alpine  
LABEL maintainer="twieren0@xs4all.net"  
  
CMD ["-f", "/var/www/html/app.php"]  
```
  
Hier voegen we een label toe en overschrijven we de default command van de base image.  
  
Voor deze demo is een git repository aangemaakt. Deze moeten we eerst binnenhalen voordat we door kunnen gaan met deze demo:
``` sh
git clone https://github.com/TijmenWierenga/docker-workshop.git demo
cd demo
git checkout feature/dockerfile
```

Om de image te creëren run je het volgende command:  
``` sh  
docker build -t xs4all/counter:dev ./app
```  
  
Na het bouwen kunnen we de image draaien met `docker run`:  
``` sh  
docker run --rm xs4all/counter:dev  
```  
  
De response is logisch:  
``` sh  
Could not open input file: /var/www/html/app.php  
```  
  
We hebben gespecificeerd dat onze container het php-bestand `/var/www/html/app.php` moet uitvoeren, echter bestaat dit bestand niet in onze container. Om dit te bewerkstelligen moeten we wederom een volume mounten om de applicatie draaiend te krijgen:  
``` sh  
docker run --rm -v $(pwd)/app.php:/var/www/html/app.php xs4all/counter:dev  
```  
  
Nu `app.php` in de container draait kunnen we onze app draaien, echter heeft de applicatie nog zijn eigen dependencies:  
``` sh   
Warning: require_once(vendor/autoload.php): failed to open stream: No such file or directory in /var/www/html/app.php on line 2  
  
Fatal error: require_once(): Failed opening required 'vendor/autoload.php' (include_path='.:/usr/local/lib/php') in /var/www/html/app.php on line 2  
```

In dit geval kunnen we Docker gebruiken om onze composer dependencies te installeren zonder composer op ons OS te installeren:
``` sh
docker run -it --rm -v $(pwd):/app -u $(id -u):$(id- g) composer install
```

Nu kunnen we onze app draaien, mits we ook onze vendor folder in de container mounten:
``` sh
docker run --rm -v $(pwd)/app.php:/var/www/html/app.php -v $(pwd)/vendor:/var/www/html/vendor xs4all/counter:dev
```

### Killing dependencies
Ondanks dat de applicatie nu draait, heeft deze implementatie een harde dependency op het lokale filesystem. We streven nog steeds naar een container die `ephemeral` is:
> The image defined by your `Dockerfile` should generate containers that are as ephemeral as possible. By “ephemeral,” we mean that the container can be stopped and destroyed, then rebuilt and replaced with an absolute minimum set up and configuration. *- Docker Best Practises*

Om dit te verbeteren kunnen we onze source code onderdeel van de repository maken. Dit doen we door  `COPY` statements in onze Dockerfile te zetten:
``` sh
FROM php:7.2-alpine  
LABEL maintainer="twieren0@xs4all.net"  

COPY app.php /var/www/html/app.php
COPY vendor /var/www/html/vendor

CMD ["-f", "/var/www/html/app.php"]
```

Wanneer we de Dockerfile nu bouwen, zijn al onze dependencies geïntegreerd in de image. Laten we de applicatie nogmaals opnieuw bouwen:
``` sh
docker build -t xs4all/counter:dev .
```

En runnen:
``` sh
docker run --rm xs4all/counter:dev
```

### Multi-stage builds
De laatste dependency die we hebben zijn onze composer dependencies. Even geleden hebben we onze composer dependencies geïnstalleerd met een Docker command om onze `vendor` map te maken. Dit betekent dat iedereen deze applicatie wil bouwen, dit ook moet doen. Dit kunnen we oplossen door een multi-stage build te gebruiken.

``` sh
FROM composer:latest as composer  
  
FROM php:7.2-alpine  
LABEL maintainer="twieren0@xs4all.net"  
  
COPY --from=composer /usr/bin/composer /usr/bin/composer  
  
RUN mkdir -p /var/www/html && chown -R www-data:www-data /var/www/html  
  
USER www-data  
WORKDIR /var/www/html  
  
COPY --chown=www-data . /var/www/html/  
  
RUN composer install --no-scripts --no-autoloader  
RUN composer dump-autoload --optimize  
  
CMD ["-f", "/var/www/html/app.php"]
```

We gebruiken hier tweemaal een `FROM` statement. We hebben nog steeds onze `php` base image, maar we gebruiken nu ook een 'intermediate' `composer` container. Deze container kan worden gebruikt om artifacts te creëren om die vervolgens naar de base image te kopiëren. In ons geval gebruiken we de `/usr/bin/composer` binary die we naar onze base image kopiëren.

Containers erven het authenticatie-systeem van de base image. In dit geval moeten we de juiste rechten instellen voor de user die we gebruiken om onze app te draaien: `www-data`. We voorkomen hiermee ook dat `composer` als `root` runt, wat bekend staat als een security bad practice.

Vervolgens kopiëren we de source code in zijn volledigheid naar de `/var/www/html/` directory. De `Dockerfile` zelf en de `.gitignore` file zijn niet nodig in de image, dus die excluden we middels een `.dockerignore`.

Tenslotte draaien we `composer install` en `composer dump-autoload` als twee afzonderlijke commands. De reden hiervoor is dat `composer install` enkel een dependency heeft op `composer.json` en `composer.lock` en de `composer dump-autoload` alles source files nodig heeft. Omdat Docker gebruik maakt van build-cache maken we hierdoor optimaal gebruik van caching. Dit voorkomt dat we iedere keer opnieuw een `composer install` moeten draaien terwijl we enkel onze autoloader hoeven te herbouwen.
