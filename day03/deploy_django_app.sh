#!/bin/bash

# Deploy a Django app and handle errors

# Function to clone the Django app code
code_clone() {
    echo "Cloning the Django app..."
    if [ -d "django-notes-app" ]; then
        echo "The code directory already exists. Skipping clone."
    else
        git clone https://github.com/LondheShubham153/django-notes-app.git || {
            echo "Failed to clone the code."
            return 1
        }
    fi
}

# Function to install required dependencies
install_requirements() {
    echo "Installing dependencies..."
    sudo apt-get update && sudo apt-get install -y docker.io docker-compose || {
        echo "Failed to install dependencies."
        return 1
    }
}

# Function to perform required restarts
required_restarts() {
    echo "Performing required restarts..."
    sudo chown "$USER" /var/run/docker.sock || {
        echo "Failed to change ownership of docker.sock."
        return 1
    }
}

# Function to create .dockerignore to avoid permission issues
create_dockerignore() {
    echo "Creating .dockerignore file to avoid permission errors..."
    cat <<EOF > .dockerignore
data/
*.dblwr
*.pid
*.sock
*.log
__pycache__/
*.pyc
.env
EOF
}

# Function to deploy the Django app
deploy() {
    echo "Building and deploying the Django app..."
    docker-compose down
    docker-compose up --build -d || {
        echo "Failed to build and deploy the app."
        return 1
    }
}

# Main deployment script
echo "********** DEPLOYMENT STARTED *********"

# Step 1: Clone the code
if ! code_clone; then
    echo "Cloning failed. Exiting..."
    exit 1
fi

# Step 2: Change directory into the Django app
cd django-notes-app || {
    echo "Failed to enter the django-notes-app directory. Exiting..."
    exit 1
}

# Step 3: Install dependencies
if ! install_requirements; then
    exit 1
fi

# Step 4: Perform required restarts
if ! required_restarts; then
    exit 1
fi

# Step 4.5: Create .dockerignore file
create_dockerignore

# Step 5: Deploy the app
if ! deploy; then
    echo "Deployment failed. Mailing the admin..."
    # Add your sendmail or notification logic here
    exit 1
fi

echo "********** DEPLOYMENT DONE *********"
echo "App should now be accessible at: http://<your-server-ip>:8080"
