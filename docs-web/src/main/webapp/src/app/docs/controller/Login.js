'use strict';

/**
 * Login controller.
 */
angular.module('docs').controller('Login', function(Restangular, $scope, $rootScope, $state, $stateParams, $dialog, User, $translate, $uibModal) {
  $scope.codeRequired = false;

  // Get the app configuration
  Restangular.one('app').get().then(function(data) {
    $rootScope.app = data;
  });

  // Login as guest
  $scope.loginAsGuest = function() {
    $scope.user = {
      username: 'guest',
      password: ''
    };
    $scope.login();
  };
  
  // Login
  $scope.login = function() {
    User.login($scope.user).then(function() {
      User.userInfo(true).then(function(data) {
        $rootScope.userInfo = data;
      });

      if($stateParams.redirectState !== undefined && $stateParams.redirectParams !== undefined) {
        $state.go($stateParams.redirectState, JSON.parse($stateParams.redirectParams))
          .catch(function() {
            $state.go('document.default');
          });
      } else {
        $state.go('document.default');
      }
    }, function(data) {
      if (data.data.type === 'ValidationCodeRequired') {
        // A TOTP validation code is required to login
        $scope.codeRequired = true;
      } else {
        // Login truly failed
        var title = $translate.instant('login.login_failed_title');
        var msg = $translate.instant('login.login_failed_message');
        var btns = [{result: 'ok', label: $translate.instant('ok'), cssClass: 'btn-primary'}];
        $dialog.messageBox(title, msg, btns);
      }
    });
  };

  // Password lost
  $scope.openPasswordLost = function () {
    $uibModal.open({
      templateUrl: 'partial/docs/passwordlost.html',
      controller: 'ModalPasswordLost'
    }).result.then(function (username) {
      if (username === null) {
        return;
      }

      // Send a password lost email
      Restangular.one('user').post('password_lost', {
        username: username
      }).then(function () {
        var title = $translate.instant('login.password_lost_sent_title');
        var msg = $translate.instant('login.password_lost_sent_message', { username: username });
        var btns = [{result: 'ok', label: $translate.instant('ok'), cssClass: 'btn-primary'}];
        $dialog.messageBox(title, msg, btns);
      }, function () {
        var title = $translate.instant('login.password_lost_error_title');
        var msg = $translate.instant('login.password_lost_error_message');
        var btns = [{result: 'ok', label: $translate.instant('ok'), cssClass: 'btn-primary'}];
        $dialog.messageBox(title, msg, btns);
      });
    });
  };

  // 新增：打开注册对话框
  $scope.openRegistrationRequest = function() {
    $uibModal.open({
      templateUrl: 'partial/docs/registration_request.html', // 注册表单模板
      controller: 'RegistrationRequestController',
      backdrop: 'static', // 点击背景不关闭
      keyboard: false // ESC键不关闭
    }).result.then(function(registrationData) {
      // 处理注册请求
      Restangular.one('user').post('register_request', registrationData)
          .then(function() {
            // 注册成功
            var title = $translate.instant('registration.success_title');
            var msg = $translate.instant('registration.success_message');
            var btns = [{result: 'ok', label: $translate.instant('ok'), cssClass: 'btn-primary'}];
            $dialog.messageBox(title, msg, btns);
          }, function(response) {
            // 注册失败
            var errorMsg;
            switch (response.data.type) {
              case 'ValidationError':
                errorMsg = $translate.instant('registration.validation_error');
                break;
              case 'AlreadyExistingUsername':
                errorMsg = $translate.instant('registration.username_exists');
                break;
              default:
                errorMsg = $translate.instant('registration.error');
            }

            var title = $translate.instant('registration.error_title');
            var btns = [{result: 'ok', label: $translate.instant('ok'), cssClass: 'btn-primary'}];
            $dialog.messageBox(title, errorMsg, btns);
          });
    });
  };
});

// 新增：注册对话框控制器
angular.module('docs').controller('RegistrationRequestController', function($scope, $uibModalInstance, $translate) {
  $scope.registrationData = {
    username: '',
    password: '',
    email: ''
  };

  $scope.submitRegistration = function() {
    // 基本表单验证
    if (!$scope.registrationData.username || !$scope.registrationData.password || !$scope.registrationData.email) {
      var title = $translate.instant('registration.error_title');
      var msg = $translate.instant('registration.required_fields');
      var btns = [{result: 'ok', label: $translate.instant('ok'), cssClass: 'btn-primary'}];
      $dialog.messageBox(title, msg, btns);
      return;
    }

    // 关闭对话框并返回注册数据
    $uibModalInstance.close($scope.registrationData);
  };

  $scope.cancel = function() {
    $uibModalInstance.dismiss('cancel');
  };
});