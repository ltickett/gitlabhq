import initSettingsPanels from '~/settings_panels';
import initDeployKeys from '~/deploy_keys';
import ProtectedBranchCreate from '~/protected_branches/protected_branch_create';
import ProtectedBranchEditList from '~/protected_branches/protected_branch_edit_list';

document.addEventListener('DOMContentLoaded', () => {
  initDeployKeys();
  initSettingsPanels();
  new ProtectedBranchCreate(); // eslint-disable-line no-new
  new ProtectedBranchEditList(); // eslint-disable-line no-new
});
