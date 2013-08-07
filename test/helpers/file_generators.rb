module FileGenerators

  TEMP_FILE_PATH = File.expand_path('../../test_files/', __FILE__)

  def make_scheduler_file_1_job(extra_values = {})
    FileUtils.mkdir_p TEMP_FILE_PATH
    filename = File.join(TEMP_FILE_PATH, 'single_job.yml')
    file_contents = make_single_job_yaml('Big Ass Job', "* * * * *")
    File.open(filename, 'w') { |file| file.write(file_contents) }
    filename
  end

  private

  def make_single_job_yaml(name, cron_schedule, other = {})
    ## example entry
    #delete_old_job_states:
    #    worker_class: JobState
    #    worker_method: delete_old_finished
    #    for_each_vhost: true
    #    cron_schedule: "0 1 * * *"

    job_details = other.clone
    job_details['cron_schedule'] = cron_schedule

    job_hash = {name => job_details}

    job_hash.to_yaml
  end


end