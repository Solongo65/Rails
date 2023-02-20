# Base image
FROM --platform=linux/amd64 ruby:3.1.0-alpine 

# Install system dependencies
RUN apk update && apk add --no-cache build-base postgresql-dev tzdata

# Set the working directory
WORKDIR /app

# Install gems
COPY Gemfile Gemfile.lock ./

RUN bundle install --jobs $(nproc) --retry 3

# Copy the application code into the container
COPY . .

# Set the environment variable
# ENV RAILS_ENV development

# Expose port 3000
EXPOSE 3000

# Start the Rails server
CMD ["bundle", "exec", "rails", "s", "-p", "3000", "-b", "0.0.0.0"]


