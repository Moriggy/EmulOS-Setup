BETA PARA (RPI4) Utilice este método de instalación manual en su lugar. Esto solo ha sido probado en raspbian lite.

Para una compilación de retropie muy wip, tendrá que instalarlo manualmente. 

1) Instala raspbian lite. 

2) Instala Git. 

3) Luego escriba: 

git clone --branch fkms_rpi4 --depth=1 https://github.com/Moriggy/EmulOS-Setup.git

4) Habilite el controlador GL (Fake KMS) en raspi-config.

sudo raspi-config

![Test Image 1](https://github.com/DOCK-PI3/MasOS-Setup/blob/fkms_rpi4/tools/FELIZ_tenor.gif)







EmulOS-Setup es una evolución de MasOS (fork de RetroPie) en español que fue creado en verano de 2018.
==============

Uso General
-------------

Script de Shell para configurar Raspberry Pi, Vero4K, ODroid-C1 o una PC + Ubuntu con muchos emuladores y juegos, EmulOS usando EmulationStation como interfaz gráfica. Las imágenes preinstaladas de inicio para Raspberry Pi están disponibles para aquellos que desean un sistema listo para usar, descargables desde la sección de descargas nuestro sitio web http://masos.dx.am

Este script está diseñado para su uso en Raspbian en el Rasperry Pi, OSMC , Vero4K , ODroid-C1 o una PC de 32 u 64bit.

Para ejecutar el script de configuración de EmulOS, asegúrese de que sus repositorios APT estén actualizados y de que Git esté instalado:

```shell
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get install -y git
```

Luego puede descargar la última secuencia de comandos de configuración de EmulOS

```shell
cd
git clone --depth=1 https://github.com/Moriggy/EmulOS-Setup.git
```

```shell
cd EmulOS-Setup
sudo ./emulos_setup.sh
```

Cuando ejecuta el script por primera vez, puede instalar algunos paquetes adicionales que sean necesarios


Binarios y fuentes
--------------------

En la Raspberry Pi, la configuración de EmulOS ofrece la posibilidad de instalar desde binarios o fuente. Para otras plataformas compatibles, solo está disponible una instalación de origen. Se recomienda instalar desde binario en una Raspberry Pi, ya que construir todo desde la fuente puede llevar mucho tiempo.

Para obtener más información, visite la web en http://masos.dx.am o el repositorio en https://github.com/Moriggy/EmulOS-Setup.


GRACIAS!
------

Esta secuencia de comandos simplemente simplifica el uso de las grandes obras de muchas otras personas que disfrutan del espíritu de retrogaming. ¡Muchas gracias a todos ellos!
