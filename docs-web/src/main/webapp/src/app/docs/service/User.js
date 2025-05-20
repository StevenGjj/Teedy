'use strict';

/**
 * User service.
 */
angular.module('docs').factory('User', function(Restangular) {
  var userInfo = null;
  
  return {
    /**
     * Returns user info.
     * @param force If true, force reloading data
     */
    userInfo: function(force) {
      if (userInfo === null || force) {
        userInfo = Restangular.one('user').get();
      }
      return userInfo;
    },
    
    /**
     * Login an user.
     */
    login: function(user) {
      return Restangular.one('user').post('login', user);
    },
    
    /**
     * Logout the current user.
     */
    logout: function() {
      return Restangular.one('user').post('logout', {});
    },

    // 获取待审批用户列表
    getPendingUsers: function() {
      return Restangular.one('user').getList('pending');
    },

    // 审批用户（接受） - 调用已有的API
    approveUser: function(userId) {
      return Restangular.one('user', 'approve').one(userId).post('');
    },

    // 审批用户（拒绝） - 调用已有的API
    rejectUser: function(userId) {
      return Restangular.one('user', 'reject').one(userId).post('');
    }
  }
});