module FileGenerators

  TEMP_FILE_PATH = File.expand_path('../../test_files/', __FILE__)
  EXAMPLE_CRON = ["* * * * *", "0 0 * * *", "0 1 * * *", "*/10 * * * *", "5,15,25,35,45,55 * * * *", "* */2 * * *", "45 15,17,19,21,23 * * *", "0 16,18,20,22,24 * * *",  "0 10 * * *",  "0 * 0 *  *"]

  def make_scheduler_file_1_job(job_name, job_cron, extra_values = {})
    FileUtils.mkdir_p TEMP_FILE_PATH
    filename = File.join(TEMP_FILE_PATH, 'single_job.yml')
    file_contents = make_single_job_yaml(job_name, job_cron, extra_values)
    File.open(filename, 'w') { |file| file.write(file_contents) }
    filename
  end

  def make_scheduler_file_n_jobs(n)
    FileUtils.mkdir_p TEMP_FILE_PATH
    filename = File.join(TEMP_FILE_PATH, 'multiple_jobs.yml')

    file_contents = ''
    (1..n).each do |i|
      name = "#{rand(36**8).to_s(36)}_#{i}"
      cron = EXAMPLE_CRON[(i - 1) % EXAMPLE_CRON.length]
      other_params = {}
      rand(5).times { other_params[rand(36**10).to_s(36)] = rand(36**22).to_s(36) }
      file_contents += make_single_job_yaml(name, cron, other_params) + "\n"
    end

    File.open(filename, 'w') { |file| file.write(file_contents) }
    filename
  end

  def clear_test_files
    if File.exist? FileGenerators::TEMP_FILE_PATH
      Dir[File.join(FileGenerators::TEMP_FILE_PATH, "*.yml")].each { |f| FileUtils.rm_rf f }
      Dir.delete(FileGenerators::TEMP_FILE_PATH)
    end
  end

  private

  def make_single_job_yaml(name, cron_schedule, other = {})
    ## example entry
    #name:
    #    cron_schedule: "0 1 * * *"
    #    worker_class: Class1
    #    worker_method: method_two
    #    some_other_param: true
    #    one_more_param: 240

    job_hash = {name => {'cron_schedule' => cron_schedule}}
    job_hash[name].merge!(other)

    job_hash.to_yaml.gsub("--- \n", '')
  end


end