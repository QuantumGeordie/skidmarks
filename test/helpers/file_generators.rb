module FileGenerators

  TEMP_FILE_PATH = File.expand_path('../../test_files/', __FILE__)
  EXAMPLE_CRON = ["* * * * *", "0 0 * * *", "0 1 * * *", "*/10 * * * *", "5,15,25,35,45,55 * * * *", "* */2 * * *", "45 15,17,19,21,23 * * *", "0 16,18,20,22,24 * * *",  "0 10 * * *",  "0 * 0 *  *"]

  def make_scheduler_file_1_job(job_name, job_cron, extra_values = {})
    filename = prep_temp_file('single_job.yml')

    file_contents = make_single_job_yaml(job_name, job_cron, extra_values)
    File.open(filename, 'w') { |file| file.write(file_contents) }
    filename
  end

  def make_scheduler_file_n_jobs(n)
    filename = prep_temp_file('multiple_jobs.yml')

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

  def make_scheduler_file_multiple_jobs(job_names, job_crons)
    raise 'Number of Job Names must equal number of Job Crons' unless job_names.length == job_crons.length

    filename = prep_temp_file('multiple_jobs.yml')

    file_contents = ''
    i = 0
    job_names.each do |name|
      file_contents += make_single_job_yaml(name, job_crons[i]) + "\n"
      i += 1
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

  def prep_temp_file(filename)
    FileUtils.mkdir_p TEMP_FILE_PATH
    File.join(TEMP_FILE_PATH, filename)
  end

  def make_single_job_yaml(name, cron_schedule, other = {})
    job_hash = {name => {'cron_schedule' => cron_schedule}}
    job_hash[name].merge!(other)

    job_yaml = job_hash.to_yaml
    job_yaml = job_yaml.gsub("--- \n", '')   # ruby 1.8.7 adds this
    job_yaml = job_yaml.gsub("---\n", '')    # ruby 1.9.3 adds this
    job_yaml
  end


end