App = {
  web3Provider: null,
  contracts: {},

  init: async function() {
      $.getJSON('FlipCoin.json', function(flipCoinArtifact) {
            App.contracts.FlipCoin = TruffleContract(flipCoinArtifact); 
            App.contracts.FlipCoin.setProvider(App.web3Provider); 
            App.listenToEvents(); 
            return App.reloadBets(); 
      }); 
  },

  initWeb3: async function() {
      if (typeof web3 != 'undefined') {
          App.web3Provider = web3.currentProvider; 
          web3 = new Web3(web3.currentProvider); 
      } else {
          // set the provider from web3 providers. 
          App.web3Provider = new Web3.providers.HttpProvider('http://localhost:9545'); 
          web3 = new Web3(App.web3Provider); 
      }
  },

  initContract: function() {
    /*
     * Replace me...
     */

    return App.bindEvents();
  },

  bindEvents: function() {
    $(document).on('click', '.btn-adopt', App.handleAdopt);
  },

  markAdopted: function() {
    /*
     * Replace me...
     */
  },

  handleAdopt: function(event) {
    event.preventDefault();

    var petId = parseInt($(event.target).data('id'));

    /*
     * Replace me...
     */
  }

};

$(function() {
  $(window).load(function() {
    App.init();
  });
});
