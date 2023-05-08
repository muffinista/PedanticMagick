FROM ruby:2.6.5-slim

RUN apt-get update -qq && apt-get install -qq --no-install-recommends \
    git libidn11-dev build-essential libsqlite3-dev libcurl4-openssl-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


WORKDIR /app
ADD Gemfile* /app/
RUN bundle install

COPY . /app

CMD ["bundle", "exec", "./PedanticMagick.rb"]
