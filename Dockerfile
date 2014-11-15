FROM ubuntu

EXPOSE 80

RUN apt-get update
RUN apt-get install -y apache2 ruby ruby-dev make python-pip git
RUN apt-get install -y npm nodejs nodejs-legacy
RUN pip install pygments
RUN gem install bundler
RUN npm config set registry http://registry.npmjs.org/
RUN npm install -g grunt-cli bower

VOLUME ["/data"]
WORKDIR /data
