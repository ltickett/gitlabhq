/* eslint-disable func-names, no-var, object-shorthand, one-var, no-else-return */

import $ from 'jquery';
import Api from './api';
import ProjectSelectComboButton from './project_select_combo_button';

export default function projectSelect() {
  $('.ajax-project-select').each(function(i, select) {
    var placeholder;
    const simpleFilter = $(select).data('simpleFilter') || false;
    this.groupId = $(select).data('groupId');
    this.includeGroups = $(select).data('includeGroups');
    this.allProjects = $(select).data('allProjects') || false;
    this.orderBy = $(select).data('orderBy') || 'id';
    this.withIssuesEnabled = $(select).data('withIssuesEnabled');
    this.withMergeRequestsEnabled = $(select).data('withMergeRequestsEnabled');
    this.allowClear = $(select).data('allowClear') || false;

    placeholder = 'Search for project';
    if (this.includeGroups) {
      placeholder += ' or group';
    }

    $(select).select2({
      placeholder: placeholder,
      minimumInputLength: 0,
      query: (function(_this) {
        return function(query) {
          var finalCallback, projectsCallback;
          finalCallback = function(projects) {
            var data;
            data = {
              results: projects,
            };
            return query.callback(data);
          };
          if (_this.includeGroups) {
            projectsCallback = function(projects) {
              var groupsCallback;
              groupsCallback = function(groups) {
                var data;
                data = groups.concat(projects);
                return finalCallback(data);
              };
              return Api.groups(query.term, {}, groupsCallback);
            };
          } else {
            projectsCallback = finalCallback;
          }
          if (_this.groupId) {
            return Api.groupProjects(
              _this.groupId,
              query.term,
              {
                with_issues_enabled: _this.withIssuesEnabled,
                with_merge_requests_enabled: _this.withMergeRequestsEnabled,
              },
              projectsCallback,
            );
          } else {
            return Api.projects(
              query.term,
              {
                order_by: _this.orderBy,
                with_issues_enabled: _this.withIssuesEnabled,
                with_merge_requests_enabled: _this.withMergeRequestsEnabled,
                membership: !_this.allProjects,
              },
              projectsCallback,
            );
          }
        };
      })(this),
      id: function(project) {
        if (simpleFilter) return project.id;
        return JSON.stringify({
          name: project.name,
          url: project.web_url,
        });
      },
      text: function(project) {
        return project.name_with_namespace || project.name;
      },

      initSelection: function(el, callback) {
        return Api.project(el.val()).then(({ data }) => callback(data));
      },

      allowClear: this.allowClear,

      dropdownCssClass: 'ajax-project-dropdown',
    });
    if (simpleFilter) return select;
    return new ProjectSelectComboButton(select);
  });
}
