# Safeway

## Getting started

### Database - Setup guide

Safeway app uses PostgreSQL to store all of its information.

#### macOS
It is assumed that Homebrew is used as package manager by most of the users. If you have used Postgres previously you are free to skip this step.

1. Install Postgres via brew `brew install postgresql`. Configure it according to the console's output.
2. Start the service `brew service start postgresql`.
3. Run the psql CLI `psql postgres`.
4. Create a user (later input this data into db config file in rails config directory) `CREATE ROLE username WITH LOGIN PASSWORD 'quoted password' [OPTIONS]`.

#### Ubuntu
Please refer to Digital Ocean's [guide](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-postgresql-on-ubuntu-18-04) to setup your local enviroment.

#### Windows
Application is not intended to work under Windows OS.

### Running app locally

1. Switch to proper gemset `rvm use 2.6.3@safeway`.
2. Install dependencies `bundle install --without production`.
3. Setup your database:
    * Prepare configuration file `cp config/database.example.yml config/database.yml`.
    * Insert proper values in the `username` and `password` fields in created file.
    * Create local database `rake db:create`.
    * Run migrations `rake db:migrate`.
    * Optional: Plenty of seeds were prepared in order to provide sample data for manual testing. Additionaly, seeds contain master admin's account credentials. To run them, tpye `rake db:seed`.
4. Setup your secrets file:
    * Prepare secrets file `cp config/secrets.example.yml config/secrets.yml`.
5. Run the test suite. This project uses `rspec` as its test engine, so in order to do this type `rspec` in your terminal window. If any of the specs fail, please do notify us and create an issue which will contain rspec's output.
6. Run linters. Currently `rubocop` and `haml-lint` are used. Run `rubocop; haml-lint`. If any warnings occur please do notify us, and create an issue will which contain linter's output.
7. If up to this moment everything worked fine, you are free to run `rails s` and navigate to `localhost:3000`. You are ready to start writing code.


### API docs

#### GitLab pages
[SafewayAPI](http://sternkraft.pages.binarapps.com/safeway/api/) - API provided by our application.

#### Running API docs locally

* Install dependency called live-server `npm install -g live-server`.
* Navigate to doc/ folder `cd doc`.
* Run live server `live-server --port=8888`.
* Copy host on which is running our server. (`http://127.0.0.1:8888`)
* Go to browser and type the address `http://127.0.0.1:8888/api_doc_local.html`.

## Environments

### Production

Production app is available at https://admin.cargosecurity.online/

SSH connection details are in `config/deploy/production.rb`

### Staging

Staging app is available at https://admin.staging.cargosecurity.online/

SSH connection details are in `config/deploy/staging.rb`

## Technologies

* PostgreSQL
* Rails 5.2
* Ruby 2.6
* [Bulma](https://bulma.io/)
* [cash](http://kenwheeler.github.io/cash/)
