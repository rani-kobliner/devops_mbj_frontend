log_info() {
    echo "[INFO] $1"
}

log_error() {
    echo "[ERROR] $1"
}

# 1. Check for Git changes, commit, and push
log_info "Checking for changes in Git..."
if [[ -n $(git status --porcelain) ]]; then
    log_info "Changes detected. Staging, committing, and pushing to GitHub..."
    git add .
    git commit -m "Automated commit: $(date)"
    git push origin $BRANCH
else
    log_info "No changes to commit."
fi

# 2. Install dependencies and build the app
log_info "Installing dependencies and building the app..."
if command -v npm &> /dev/null; then
    npm install
    npm run build
else
    log_error "npm is not installed or not in PATH. Aborting."
    exit 1
fi

# 3. Upload the built files to the GCS bucket
log_info "Uploading files to GCS bucket: $GCS_BUCKET..."
if gsutil -m cp -r $BUILD_DIR/* gs://$GCS_BUCKET/; then
    log_info "Files successfully uploaded to GCS bucket."
else
    log_error "Failed to upload files to GCS bucket."
    exit 1
fi

# Script complete
log_info "Deployment process completed successfully."
