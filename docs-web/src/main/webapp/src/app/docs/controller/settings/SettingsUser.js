'use strict';

/**
 * Settings user page controller.
 */
angular.module('docs').controller('SettingsUser', function($scope, $state, Restangular) {
  /**
   * Load users from server.
   */
  $scope.loadUsers = function() {
    Restangular.one('user/list').get({
      sort_column: 1,
      asc: true
    }).then(function(data) {
      $scope.users = data.users;
    });
  };
  
  $scope.loadUsers();
  
  /**
   * Edit a user.
   */
  $scope.editUser = function(user) {
    $state.go('settings.user.edit', { username: user.username });
  };

  // ----------------------
  // 新增：管理员审核功能
  // ----------------------
  $scope.isAdmin = false; // 权限标识
  $scope.tab = 'users'; // 标签页状态
  $scope.dateFormat = 'yyyy-MM-dd HH:mm';
  $scope.pendingUsers = []; // 待审批用户列表
  $scope.pendingCount = 0; // 待审批数量

  // 获取用户权限信息
  User.userInfo().then(function(userData) {
    $scope.isAdmin = userData.base_functions.includes('ADMIN'); // 判断是否为管理员
    if ($scope.isAdmin) {
      $scope.loadPendingUsers(); // 加载待审批用户
    }
  });

  // 加载待审批用户列表
  $scope.loadPendingUsers = function() {
    if (!$scope.isAdmin) return; // 非管理员不加载

    User.getPendingUsers().then(function(users) {
      $scope.pendingUsers = users.map(user => ({
        id: user.id,
        username: user.username,
        email: user.email,
        registrationDate: new Date(user.registrationDate)
      }));
      $scope.pendingCount = $scope.pendingUsers.length;
    }).catch(error => {
      console.error('加载待审批用户失败:', error);
      $dialog.messageBox(
          $translate.instant('error.title'),
          $translate.instant('settings.user.load_pending_error'),
          [{ result: 'ok', label: $translate.instant('ok') }]
      );
    });
  };

  // 审批用户（接受）
  $scope.approveUser = function(userId) {
    $uibModal.open({
      title: $translate.instant('settings.user.approve_confirm_title'),
      template: `
        <div class="modal-body">
          {{ 'settings.user.approve_confirm_message' | translate }}
        </div>
        <div class="modal-footer">
          <button class="btn btn-success" ng-click="ok()">
            {{ 'yes' | translate }}
          </button>
          <button class="btn btn-default" ng-click="dismiss()">
            {{ 'no' | translate }}
          </button>
        </div>
      `,
      controller: function($scope, $uibModalInstance) {
        $scope.ok = () => {
          User.approveUser(userId).then(() => {
            $uibModalInstance.close();
            $dialog.messageBox(
                '',
                $translate.instant('settings.user.approved_success'),
                [{ result: 'ok', label: $translate.instant('ok') }]
            );
            $scope.loadPendingUsers(); // 刷新待审批列表
          }).catch(error => {
            $dialog.messageBox(
                '',
                $translate.instant('settings.user.approved_error'),
                [{ result: 'ok', label: $translate.instant('ok') }]
            );
          });
        };
        $scope.dismiss = () => $uibModalInstance.dismiss();
      }
    });
  };

  // 拒绝用户（拒绝）
  $scope.rejectUser = function(userId) {
    $uibModal.open({
      title: $translate.instant('settings.user.reject_confirm_title'),
      template: `
        <div class="modal-body">
          {{ 'settings.user.reject_confirm_message' | translate }}
        </div>
        <div class="modal-footer">
          <button class="btn btn-danger" ng-click="ok()">
            {{ 'yes' | translate }}
          </button>
          <button class="btn btn-default" ng-click="dismiss()">
            {{ 'no' | translate }}
          </button>
        </div>
      `,
      controller: function($scope, $uibModalInstance) {
        $scope.ok = () => {
          User.rejectUser(userId).then(() => {
            $uibModalInstance.close();
            $dialog.messageBox(
                '',
                $translate.instant('settings.user.rejected_success'),
                [{ result: 'ok', label: $translate.instant('ok') }]
            );
            $scope.loadPendingUsers(); // 刷新待审批列表
          }).catch(error => {
            $dialog.messageBox(
                '',
                $translate.instant('settings.user.rejected_error'),
                [{ result: 'ok', label: $translate.instant('ok') }]
            );
          });
        };
        $scope.dismiss = () => $uibModalInstance.dismiss();
      }
    });
  };

  // 切换标签页
  $scope.setTab = function(tabName) {
    $scope.tab = tabName;
    if (tabName === 'pending') {
      $scope.loadPendingUsers(); // 切换时刷新待审批列表
    }
  };
});