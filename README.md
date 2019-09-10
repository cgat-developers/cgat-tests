# cgat-tests

Configuration files for CI

## Running cgat-test

The tests are implemented in the script pipeline_testing.py, which is itself a ruffus pipeline. See its [documentation](https://www.cgat.org/downloads/public/cgatpipelines/documentation/pipelines/pipeline_testing.html) to see how it works. To run the default CGAT pipeline tests, follow the following instructions::

    # checkout configuration files into directory tests
    git clone git@github.com:cgat-developers/cgat-tests.git

    # enter tests directory
    cd cgat-tests

    # run pipeline_testing
    python <path to code>/CGATPipelines/pipeline_testing.py make full -v 5 -p 10 

    # build report
    python <path to code>/CGATPipelines/pipeline_testing.py make build_report -v 5 -p 10 
    
This will run the default CGAT pipeline test suite and build a report. pipeline_testing.py performs the following actions:

Download the test data and reference data from a tar-ball on http://www.cgat.org/downloads/public/cgatpipelines/pipeline_test_data.
Unpack the data
Run the tests
Check the output of the tests against the reference data
