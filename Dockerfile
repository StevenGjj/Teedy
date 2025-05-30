# 使用已经包含Ubuntu 22.04的自定义镜像
FROM ubuntu:22.04
# 使用LABEL指令为镜像添加元数据，设置镜像维护者的电子邮件地址
LABEL maintainer="b.gamard@sismics.com"
# 以非交互模式运行Debian
ENV DEBIAN_FRONTEND noninteractive 
# 配置环境变量
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64/ 
ENV JAVA_OPTIONS -Dfile.encoding=UTF-8 -Xmx1g 
ENV JETTY_VERSION 11.0.20
ENV JETTY_HOME /opt/jetty 
# 安装后清理不必要的文件以减小镜像大小。安装必要的软件包和OCR语言
RUN apt-get update && \
    apt-get -y -q --no-install-recommends install \
    vim less procps unzip wget tzdata openjdk-11-jdk \
    ffmpeg \
    tesseract-ocr \
    mediainfo \
    tesseract-ocr-ara \
    tesseract-ocr-ces \
    tesseract-ocr-chi-sim \
    tesseract-ocr-chi-tra \
    tesseract-ocr-dan \
    tesseract-ocr-deu \
    tesseract-ocr-fin \
    tesseract-ocr-fra \
    tesseract-ocr-heb \
    tesseract-ocr-hin \
    tesseract-ocr-hun \
    tesseract-ocr-ita \
    tesseract-ocr-jpn \
    tesseract-ocr-kor \
    tesseract-ocr-lav \
    tesseract-ocr-nld \
    tesseract-ocr-nor \
    tesseract-ocr-pol \
    tesseract-ocr-por \
    tesseract-ocr-rus \
    tesseract-ocr-spa \
    tesseract-ocr-swe \
    tesseract-ocr-tha \
    tesseract-ocr-tur \
    tesseract-ocr-ukr \
    tesseract-ocr-vie \
    tesseract-ocr-sqi \
RUN dpkg-reconfigure -f noninteractive tzdata && apt-get clean && \
    rm -rf /var/lib/apt/lists/*
# 安装Jetty服务器
RUN wget -nv -O /tmp/jetty.tar.gz \
    "https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-home-${JETTY_VERSION}.tar.gz" \
    && tar xzf /tmp/jetty.tar.gz -C /opt \
    && mv /opt/jetty* /opt/jetty \
    && useradd jetty -U -s /bin/false \
    && chown -R jetty:jetty /opt/jetty \
    && mkdir /opt/jetty/webapps \
    && chmod +x /opt/jetty/bin/jetty.sh 
# 通知Docker容器在运行时将监听8080端口
EXPOSE 8080
# 安装应用程序
RUN mkdir /app && \
    cd /app && \
    java -jar /opt/jetty/start.jar --add-modules=server,http,webapp,deploy 
# 将本地文件docs.xml和构建好的WAR文件docs-web-*.war添加到容器的Jetty web应用目录。允许Jetty在启动时加载这些web应用
ADD docs.xml /app/webapps/docs.xml
ADD docs-web/target/docs-web-*.war /app/webapps/docs.war 
# 设置后续RUN、CMD、ENTRYPOINT、COPY和ADD指令的工作目录
WORKDIR /app 
# 设置从该镜像启动容器时将运行的默认命令。这里告诉容器通过使用Java执行start.jar文件来运行Jetty web服务器
CMD ["java", "-jar", "/opt/jetty/start.jar"]
