<p align="center"><img width="400" src="https://github.com/m41k1n4177/BurpSuite/assets/106442797/2ac09e0d-fbce-400b-982b-d30f14486f26"/>

<img src="https://portswigger.net/burp/communitydownload/images/burp-pro-logo.svg" alt="Burp Suite Professional logo" width="1080" height="400">

<h1 align="center">Welcome to <b>Burp Suite loader</b>👋</h1>


**Note:** For commercial use, please purchase genuine software from <a href="https://portswigger.net/Burp/pro" target="_blank">
  <img src="https://portswigger.net/content/images/logos/portswigger-logo.svg" alt="PortSwigger" style="max-width:100%; height:50px;">
</a>


**⚠️ Notice:** The previous version of this project was subject to a DMCA complaint from PortSwigger due to lack of obfuscation. Please review the JAR package for clarity.

If this project has been helpful, consider giving it a ⭐️ [here](https://github.com/x-Ai/BurpSuite) 🥰.

## Burp Suite Professional Download

- [Download Burp Suite Professional 2023.11.1.1 JAR](https://portswigger.net/burp/releases/download?product=pro&version=2023.11.1.1&type=Jar)
  ```bash
  wget -O burpsuite_pro.jar --quiet --show-progress https://portswigger.net/burp/releases/download?product=pro&version=2023.11.1.1&type=Jar

## Loader Options

### 1. Loader (Version Recommended)
[Download Loader (Recommended)](https://github.com/m41k1n4177/BurpSuite/blob/main/loader.jar)

```bash
wget -O loader.jar --quiet --show-progress https://github.com/m41k1n4177/BurpSuite/blob/main/loader.jar
```
### 2. Default Loader (Parent Repo)
[Download Default Loader](https://github.com/m41k1n4177/BurpSuite/blob/main/BurpSuiteLoader.jar)

```bash
wget -O BurpSuiteLoader.jar --quiet --show-progress https://github.com/m41k1n4177/BurpSuite/blob/main/BurpSuiteLoader.jar
```
Choose the loader that works best for your requirements. If in doubt, opt for the recommended version

## 🚀 Installation

⚠️ **Note:** We strongly advise **against** downloading any all-in-one installer for security reasons. Instead, follow the steps provided in this repository to download Burp Pro from an authentic source and activate it using the available loader.

## Installation Steps for Burp Suite Professional on  <a href="https://archlinux.org"><img src="https://img.shields.io/badge/Arch_Linux-1793D1?&logo=arch-linux&logoColor=white"></a>


### 1. Install dependencies & highest supported Java runtime (19):

```bash
paru -S burpsuite-pro java-environment-common java-runtime-common jre17-openjdk --noconfirm
```

### 2. Configure system to use an older runtime:
```bash
sudo archlinux-java set java-17-openjdk
```

### 3. Launch the previously installed authentic Burp Pro Java JAR with Burp Pro loader jar and turn it into an executable. 
```bash
echo "java --add-opens=java.desktop/javax.swing=ALL-UNNAMED--add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.Opcodes=ALL-UNNAMED -javaagent:$(pwd)/loader.jar -noverify -jar /usr/share/burpsuite-pro/burpsuite-pro.jar &" | sudo tee -a burpsuite
```

### 4. Specify new created executable with also executable file bits;
```bash
chmod +x burpsuite
```

### 5. Launch provided loader-activator, followed by launch of custom made burpsuite executable 
```bash
java -jar loader.jar & sleep 1s (./burpsuite)
```

## Java helper command for injecting previosuly downloaded activator into Burp. 

### 1. Updated Java helper command (Recommended)
```bash
java -noverify --add-opens=java.desktop/javax.swing=ALL-UNNAMED--add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.Opcodes=ALL-UNNAMED -javaagent:$(pwd)/loader.jar -jar burpsuite_pro.jar
```

### 2. Previous Java helper commander fallback (Parent Repo)
```bash
java -noverify -Dsun.java2d.d3d=false -Dsun.java2d.noddraw=true --add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED -javaagent:$(pwd)/BurpSuiteLoader.jar -jar burpsuite_pro.jar
```


## 📝 Discussion


If you have questions or better suggestions on how to use it, you can ask [issue](https://github.com/m41k1n4177/BurpSuite/issues).
NB! Be prepared to bear the full weight of responsibility for any incorrectly asked questions and general stupidity in my repository. 

## ❤️ Acknowledgements

The guy that got owned so hard he decided to go out and exclaim in every Burp loader repo of how much of a noob he is, ado how he managed to get infected from open source software.
Shout out to this fmaily

