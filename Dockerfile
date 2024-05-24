FROM ubuntu:22.04

ENV DEBIAN_FRONTEND noninteractive
COPY pre-install.sh /pre-install.sh
RUN /bin/bash /pre-install.sh
RUN apt-get update && apt-get install -y sudo
RUN apt-get install -y git
RUN usermod -aG sudo prairielearner
RUN passwd -d prairielearner
RUN apt-get -y install python3
RUN apt-get -y install pkg-config
RUN apt-get -y install build-essential gdb lcov pkg-config \
libbz2-dev libffi-dev libgdbm-dev libgdbm-compat-dev liblzma-dev \
libncurses5-dev libreadline6-dev libsqlite3-dev libssl-dev \
lzma lzma-dev tk-dev uuid-dev zlib1g-dev

# RUN curl -fsSL https://code-server.dev/install.sh | sh
# RUN code-server --install-extension ms-python.python
#RUN curl -fsSL https://code-server.dev/install.sh | sh
#RUN code --install-extension ms-python.python --force -y
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg \
    && install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/ \
    && sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list' \
    && apt-get update

# Install VSCode
RUN apt-get install -y code

RUN yes | code --install-extension ms-python.python --no-sandbox --user-data-dir /path/user-data --extensions-dir /path/extensions
RUN apt-get install -y unzip

COPY code.desktop /usr/share/applications/code.desktop

COPY pl-gosu-helper.sh /pl-gosu-helper.sh
COPY start-vnc.sh /start-vnc.sh
COPY config /opt/defaults/config
COPY local /opt/defaults/local
COPY server /opt/server

COPY post-install.sh /post-install.sh
RUN /bin/bash /post-install.sh

RUN echo 'prairielearner:password' | chpasswd

USER 1001
ENV PL_USER prairielearner

WORKDIR /path/to/directory
RUN git clone https://github.com/python/cpython.git
WORKDIR /path/to/directory/cpython
RUN ./configure --with-pydebug
RUN make -s -j2
COPY temp-answers.txt /path/to/directory/cpython/Lib/idlelib/temp-answers.txt






CMD /pl-gosu-helper.sh /start-vnc.sh
