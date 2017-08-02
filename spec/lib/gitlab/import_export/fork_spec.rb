require 'spec_helper'

describe 'forked project import' do
  let(:user) { create(:user) }
<<<<<<< HEAD
  let!(:project_with_repo) { create(:project, name: 'test-repo-restorer', path: 'test-repo-restorer') }
=======
  let!(:project_with_repo) { create(:project, :repository, name: 'test-repo-restorer', path: 'test-repo-restorer') }
>>>>>>> upstream/master
  let!(:project) { create(:empty_project, name: 'test-repo-restorer-no-repo', path: 'test-repo-restorer-no-repo') }
  let(:export_path) { "#{Dir.tmpdir}/project_tree_saver_spec" }
  let(:shared) { Gitlab::ImportExport::Shared.new(relative_path: project.full_path) }
  let(:forked_from_project) { create(:project, :repository) }
  let(:fork_link) { create(:forked_project_link, forked_from_project: project_with_repo) }
  let(:repo_saver) { Gitlab::ImportExport::RepoSaver.new(project: project_with_repo, shared: shared) }
  let(:bundle_path) { File.join(shared.export_path, Gitlab::ImportExport.project_bundle_filename) }

  let(:repo_restorer) do
    Gitlab::ImportExport::RepoRestorer.new(path_to_bundle: bundle_path, shared: shared, project: project)
  end

  let!(:merge_request) do
    create(:merge_request, source_project: fork_link.forked_to_project, target_project: project_with_repo)
  end

  let(:saver) do
    Gitlab::ImportExport::ProjectTreeSaver.new(project: project_with_repo, current_user: user, shared: shared)
  end

  let(:restorer) do
    Gitlab::ImportExport::ProjectTreeRestorer.new(user: user, shared: shared, project: project)
  end

  before do
    allow_any_instance_of(Gitlab::ImportExport).to receive(:storage_path).and_return(export_path)

    saver.save
    repo_saver.save

    repo_restorer.restore
    restorer.restore
  end

  after do
    FileUtils.rm_rf(export_path)
    FileUtils.rm_rf(project_with_repo.repository.path_to_repo)
    FileUtils.rm_rf(project.repository.path_to_repo)
  end

  it 'can access the MR' do
    project.merge_requests.first.ensure_ref_fetched

    expect(project.repository.ref_exists?('refs/merge-requests/1/head')).to be_truthy
  end
end
