FROM ubuntu:focal

# Update repositories
RUN apt-get update

# Install latest Python
RUN apt-get install -y python3 python3-pip && \
    update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3 1

# Install Chromium dependencies
RUN apt-get install -y --no-install-recommends \
    libnss3 \
    libxss1 \
    libasound2 \
    fonts-noto-color-emoji \
    libxtst6

# (Optional) Install XVFB if there's a need to run browsers in headful mode
RUN apt-get install -y --no-install-recommends xvfb
RUN apt-get install -y wget

RUN wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
ENV NODE_VERSION=12.20.1
ENV NVM_DIR=/root/.nvm
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"

RUN wget https://files.pythonhosted.org/packages/dc/bd/3b2163a4829f335f626f434915158ab7735b299d031c16f509bde37b66e2/playwright-1.15.3-py3-none-manylinux1_x86_64.whl
RUN mv playwright-1.15.3-py3-none-manylinux1_x86_64.whl playwright-1.15.3-py3-none-any.whl
RUN pip install playwright-1.15.3-py3-none-any.whl

RUN rm /usr/local/lib/python3.8/dist-packages/playwright/driver/node && \
    ln -s /root/.nvm/versions/node/v12.20.1/bin/node /usr/local/lib/python3.8/dist-packages/playwright/driver/node

RUN DEBIAN_FRONTEND="noninteractive" playwright install-deps
RUN playwright install chromium

## Source dir for our scripts
RUN mkdir src

# Set working dir
WORKDIR src

# Add dependencies for the scripts
COPY requirements.txt /

# Add source code for the script to be executed
COPY main.py .

# Install our dependencies
RUN pip install -r /requirements.txt

# Execute our scripts inside the container
# Important: if you need run headless=True run command with xvfb-run
#ENTRYPOINT python main.py
ENTRYPOINT xvfb-run python main.py
#ENTRYPOINT /bin/bash