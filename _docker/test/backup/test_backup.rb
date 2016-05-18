require 'minitest/autorun'
require 'mocha/mini_test'

require_relative '../../../_docker/test/test_helper'
require_relative '../../../_docker/lib/backup/backup'

class TestBackup < MiniTest::Test

  @backup_directory
  @database_name
  @drupal_filesystem
  @git_backup_strategy
  @process_runner
  @backup

  def setup
    @database_name = 'rhd_mysql'
    @backup_directory = '/backup'
    @drupal_filesystem = '/drupal'
    @git_backup_strategy = mock()
    @process_runner = mock()
    @backup = Backup.new(@drupal_filesystem, @database_name, @backup_directory, @git_backup_strategy, @process_runner)
  end

  def test_should_backup_drupal_filesystem_and_database_to_timestamped_tag

    @process_runner.expects(:execute!).with("tar -czf #{@backup_directory}/#{Backup.drupal_filesystem_tar} -C #{@drupal_filesystem} .")
    @process_runner.expects(:execute!).with("mysqldump #{@database_name} > #{@backup_directory}/#{Backup.drupal_database_sql_dump}")
    @git_backup_strategy.expects(:add_file_to_backup).with(Backup.drupal_filesystem_tar)
    @git_backup_strategy.expects(:add_file_to_backup).with(Backup.drupal_database_sql_dump)
    @git_backup_strategy.expects(:commit_backup).with(is_a(String), regexp_matches(/[0-9]{4}-([0-9]{2}-){3}[0-9]{2}/))

    @backup.execute([])

  end

  def test_should_backup_drupal_filesystem_and_database_to_named_tag

    @process_runner.expects(:execute!).with("tar -czf #{@backup_directory}/#{Backup.drupal_filesystem_tar} -C #{@drupal_filesystem} .")
    @process_runner.expects(:execute!).with("mysqldump #{@database_name} > #{@backup_directory}/#{Backup.drupal_database_sql_dump}")
    @git_backup_strategy.expects(:add_file_to_backup).with(Backup.drupal_filesystem_tar)
    @git_backup_strategy.expects(:add_file_to_backup).with(Backup.drupal_database_sql_dump)
    @git_backup_strategy.expects(:commit_backup).with(includes('my_backup'), equals('my_backup'))

    @backup.execute(%w(my_backup))

  end

end