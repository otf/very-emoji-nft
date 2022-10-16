'use strict';

// Tx Sentry - Send and listen to transactions form elm to web3 provider
export function txSentry(txFromElm, txToElm, callFromElm, callToElm, web3) {
    checkFromElmPort(txFromElm);
    checkToElmPort(txToElm);
    checkFromElmPort(callFromElm);
    checkToElmPort(callToElm);
    checkWeb3(web3);

    txFromElm.subscribe(function (txData) {
        try {
            web3.request({
              method: 'eth_sendTransaction',
              params: [ txData.txParams ]
            }).then(function (e, r) {
                txToElm.send({ ref: txData.ref, txHash: r || e });
            });
        } catch (error) {
            console.log(error);
            txToElm.send({ ref: txData.ref, txHash: null });
        }
    });

    callFromElm.subscribe(function (callData) {
        try {
            web3.request({
              method: 'eth_call',
              params: [ callData.params, "latest" ]
            }).then(function (e, r) {
                callToElm.send({ data : r || e });
            });
        } catch (error) {
            console.log(error);
            callToElm.send({ error: error });
        }
    });
}

// Wallet Sentry - listen to account and network changes
export function walletSentry(toElm, web3) {
    checkToElmPort(toElm);
    checkWeb3(web3);
    attachChainChanged(web3, toElm);
}

// Helper function that calls out to web3 for account/network
function attachChainChanged(web3, toElm) {
    let chainId = parseInt(web3.chainId ?? -1);
    let selectedAddress = web3.selectedAddress;

    toElm.send( {account: selectedAddress, networkId: chainId} );

    var handleChainChanged = function (newChainId) {
        chainId = parseInt(newChainId);
        toElm.send( {account: selectedAddress, networkId: chainId} );
    }

    var handleAccountsChanged = function (accounts) {
        selectedAddress = accounts[0];
        toElm.send( {account: selectedAddress, networkId: chainId} );
    }

    web3.on('chainChanged', handleChainChanged);
    web3.on('accountsChanged', handleAccountsChanged);
}

// Logging Helpers

function checkToElmPort(port) {
    if (typeof port === 'undefined' || typeof port.send === 'undefined') {
        console.warn('elm-ethereum-ports: The port to send messages to Elm is malformed.')
    }
}

function checkFromElmPort(port) {
    if (typeof port === 'undefined' || typeof port.subscribe === 'undefined') {
        console.warn('elm-ethereum-ports: The port to subscribe to messages from Elm is malformed.')
    }
}

function checkWeb3(web3) {
    if (typeof window.ethereum === 'undefined' && ethereum.isConnected()) {
        console.warn('elm-ethereum-ports: ethereum object is undefined, or ethereum.isConnected() is false')
    }
}
