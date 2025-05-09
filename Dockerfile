FROM python:3.12-slim

WORKDIR /pantip_etl_cronjob

# Add your source code
ADD . /pantip_etl_cronjob

# --- Timezone and Locale Setup ---
# [Optional but Recommended] Set timezone (adjust if needed)
ENV TZ=Asia/Bangkok
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies and Chromium
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    curl \
    gnupg \
    libglib2.0-0 \
    libnss3 \
    libgconf-2-4 \
    libfontconfig1 \
    libxss1 \
    libappindicator1 \
    libasound2 \
    libxtst6 \
    libxrandr2 \
    xdg-utils \
    fonts-liberation \
    libu2f-udev \
    libvulkan1 \
    cron \
    libpq-dev \
    gcc \
    chromium \
    locales `# <-- Add locales package here` \
    && \
    # Configure and generate the Thai locale
    echo "--> Configuring locale: th_TH.UTF-8" && \
    sed -i -e 's/# th_TH.UTF-8 UTF-8/th_TH.UTF-8 UTF-8/' /etc/locale.gen && \
    echo "--> Generating locales..." && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    # Clean up apt cache
    echo "--> Cleaning up apt cache" && \
    rm -rf /var/lib/apt/lists/*

# Set Environment Variables for the Locale using recommended format
ENV LANG=th_TH.UTF-8
ENV LANGUAGE=th_TH:en
ENV LC_ALL=th_TH.UTF-8
# Download and install ChromeDriver
ENV CHROME_DRIVER_VERSION=135.0.7049.95


RUN wget -O /tmp/chromedriver.zip "https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/${CHROME_DRIVER_VERSION}/linux64/chromedriver-linux64.zip" && \
    unzip /tmp/chromedriver.zip -d /tmp/ && \
    mv /tmp/chromedriver-linux64/chromedriver /usr/local/bin/chromedriver && \
    chmod +x /usr/local/bin/chromedriver && \
    rm -rf /tmp/*

# Make sure the path to Chromium and ChromeDriver are available
ENV PATH="${PATH}:/usr/bin"
ENV CHROME_BIN="/usr/bin/chromium"
ENV CHROMEDRIVER_PATH="/usr/local/bin/chromedriver"

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Add crontab
COPY crontab /etc/cron.d/crontab
RUN chmod 0644 /etc/cron.d/crontab && crontab /etc/cron.d/crontab

# Run cron in the foreground
CMD ["cron", "-f"]

# FROM python:3.12-slim

# WORKDIR /pantip_etl_cronjob

# ADD . /pantip_etl_cronjob

# # Install dependencies
# RUN apt-get update && apt-get install -y \
#     wget \
#     unzip \
#     curl \
#     gnupg \
#     libglib2.0-0 \
#     libnss3 \
#     libgconf-2-4 \
#     libfontconfig1 \
#     libxss1 \
#     libappindicator1 \
#     libasound2 \
#     libxtst6 \
#     libxrandr2 \
#     xdg-utils \
#     fonts-liberation \
#     libu2f-udev \
#     libvulkan1 \
#     cron\
#     libpq-dev\
#     gcc\
#     chromium chromium-driver \ 
#     && rm -rf /var/lib/apt/lists/*

# ENV CHROME_DRIVER_VERSION=135.0.7049.95 
# RUN wget -O /tmp/chromedriver.zip "https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/${CHROME_DRIVER_VERSION}/linux64/chromedriver-linux64.zip" && \
#     unzip /tmp/chromedriver.zip -d /usr/local/bin/ && \
#     mv /usr/local/bin/chromedriver-linux64/chromedriver /usr/local/bin/ && \
#     chmod +x /usr/local/bin/chromedriver
    

# COPY crontab /etc/cron.d/crontab

# RUN crontab /etc/cron.d/crontab

# RUN pip install -r requirements.txt

# CMD ["cron", "-f"]