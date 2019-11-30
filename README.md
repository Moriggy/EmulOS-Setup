BETA PARA (RPI4) Utilice este método de instalación manual en su lugar. Esto solo ha sido probado en raspbian buster lite y desktop.

Para una compilación de EmulOS muy VIP, tendrá que instalarlo manualmente.

1) Preparativos antes de la instalación:

a) descargar y grabar la imagen más reciente Raspbian buster Lite
b) cambiar el tamaño de la tarjeta (acción automática en la primera ejecución + reinicio)
c) conectarse a wifi, dividir la memoria (dedicar 256 MB al video), habilitar ssh y la configuración regional a en_US.UTF-8través desudo raspi-config
d) actualizar todo:sudo apt-get update -y && sudo apt-get upgrade -y && reboot
e) preinstalar algunas cosas: sudo apt-get install git lsb-release


2) Instala Git.

sudo apt-get install git


3) Luego escriba:

git clone --single-branch --branch fkms_rpi4 --depth=1 https://github.com/Moriggy/EmulOS-Setup.git


4) Habilite el controlador GL (Fake KMS) en raspi-config.

sudo raspi-config


5) Ejecutar estos pasos para completar la instalacion en rpi4

cd ./EmulOS-Setup

git fetch && git checkout fkms_rpi4

sudo ./emulos_pkgs.sh 833 depends

sudo ./emulos_pkgs.sh 833 sources

sudo ./emulos_pkgs.sh 833 build

sudo ./emulos_setup.sh

# go to basic install

#setup autostart to emulation station



![Test Image 1](https://github.com/DOCK-PI3/MasOS-Setup/blob/fkms_rpi4/tools/FELIZ_tenor.gif)


Cuando ejecuta el script por primera vez, puede instalar algunos paquetes adicionales que sean necesarios


Binarios y fuentes
--------------------

En la Raspberry Pi, la configuración de EmulOS ofrece la posibilidad de instalar desde binarios o fuente. Para otras plataformas compatibles, solo está disponible una instalación de origen. Se recomienda instalar desde binario en una Raspberry Pi, ya que construir todo desde la fuente puede llevar mucho tiempo.

Para obtener más información, visite la web en http://masos.dx.am o el repositorio en https://github.com/Moriggy/EmulOS-Setup.


GRACIAS!
------

Esta secuencia de comandos simplemente simplifica el uso de las grandes obras de muchas otras personas que disfrutan del espíritu de retrogaming. ¡Muchas gracias a todos ellos!
