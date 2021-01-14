FROM ruby:3

ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
RUN install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
RUN sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'

# RUN apt-get update -qq && apt-get install -y nodejs postgresql-client
RUN apt-get update -qq && apt-get install -y \
    apt-transport-https \
    build-essential \
    libpq-dev \
    nodejs \
    postgresql-client \
    yarn \
    vim \
    nano

WORKDIR /nginx_postgres_puma_rails
COPY Gemfile /nginx_postgres_puma_rails/Gemfile
COPY Gemfile.lock /nginx_postgres_puma_rails/Gemfile.lock
RUN bundle install
COPY . /nginx_postgres_puma_rails

# Add a script to be executed every time the container starts.
# COPY entrypoint.sh /usr/bin/
# RUN chmod +x /usr/bin/entrypoint.sh
# ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Start the main process.
CMD [ "bundle", "exec", "puma", "-C", "config/puma.rb" ]