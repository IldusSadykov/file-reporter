# File reporter
File reporter is the app for processing and report results from log file.

## Application Gems
* [minitest/autorun] (https://github.com/seattlerb/minitest)

## Getting Started
1. Clone application.

   ```bash
   git clone git://github.com/IldusSadykov/file-report.git
   ```
2. Run setup script

  ```bash
  bin/setup
  FILES_DIR=development_files REPORTS_DIR=development_reports bin/prepare_files
  FILES_DIR=test_files REPORTS_DIR=test_reports bin/prepare_files
  ```

3. Run test and quality suits to make sure all dependencies are satisfied and applications works correctly before making changes.

  ```bash
  STAGE=test REPORT_FILE_PATH=final_report_test.json bundle exec rake test
  ```

4. Run app

  ```bash
  STAGE=development REPORT_FILE_PATH=final_report.json bundle exec bin/reporter
  ```
