FROM python:alpine

# Install dependencies
RUN pip install -U shreddit

# Create working environment
RUN mkdir /app
COPY . /app
WORKDIR /app

# Run shreddit
ENTRYPOINT [ "shreddit" ]