// Web3Auth Web SDK initialization for Flutter Web
window.web3AuthInstance = null;
window.web3AuthReady = false;

async function initWeb3Auth() {
  try {
    console.log("Starting Web3Auth initialization...");
    console.log("Window.Web3auth available:", !!window.Web3auth);
    console.log("Window.Web3AuthModalPkg available:", !!window.Web3AuthModalPkg);
    console.log("All Web3 globals:", Object.keys(window).filter(k => k.toLowerCase().includes('web3')));
    
    // Try different global variable names for Web3Auth
    let Web3Auth;
    console.log("Checking window.Web3AuthCore:", !!window.Web3AuthCore);
    console.log("Checking window.Web3auth:", !!window.Web3auth);
    
    if (window.Web3AuthCore && window.Web3AuthCore.Web3Auth) {
      Web3Auth = window.Web3AuthCore.Web3Auth;
      console.log("Using window.Web3AuthCore.Web3Auth");
    } else if (window.Web3auth && window.Web3auth.Web3Auth) {
      Web3Auth = window.Web3auth.Web3Auth;
      console.log("Using window.Web3auth.Web3Auth");
    } else if (window.Web3Auth) {
      Web3Auth = window.Web3Auth;
      console.log("Using window.Web3Auth");
    } else {
      console.error("Web3Auth constructor not found. Available Web3 objects:");
      Object.keys(window).filter(k => k.toLowerCase().includes('web3')).forEach(key => {
        console.log(`- ${key}:`, typeof window[key], window[key]);
      });
      throw new Error("Web3Auth SDK not loaded properly");
    }
    
    const web3auth = new Web3Auth({
      clientId: "BPPbhL4egAYdv3vHFVQDhmueoOJKUeHJZe2X8LaMvMIq9go2GN72j6OwvheQkR2ofq8WveHJQtzNKaq0_o_xKuI",
      web3AuthNetwork: "sapphire_devnet",
      chainConfig: {
        chainNamespace: "other",
        chainId: "0x534e5f5345504f4c4941", // Starknet Sepolia
        rpcTarget: "https://starknet-sepolia.public.blastapi.io",
      },
    });

    await web3auth.initModal();
    window.web3AuthInstance = web3auth;
    window.web3AuthReady = true;
    
    console.log("Web3Auth initialized successfully");
    
    // Notify Flutter that Web3Auth is ready
    if (window.flutter_web3auth_ready) {
      window.flutter_web3auth_ready();
    }
    
    return web3auth;
  } catch (error) {
    console.error("Web3Auth initialization failed:", error);
    throw error;
  }
}

// Auto-initialize when page loads
window.addEventListener('load', function() {
  console.log("Page fully loaded, starting Web3Auth init...");
  // Wait for Web3Auth scripts to load
  setTimeout(function() {
    console.log("Attempting Web3Auth initialization after delay...");
    initWeb3Auth().catch(console.error);
  }, 2000); // Increased delay
});

// Web3Auth helper functions for Flutter
window.web3AuthLogin = async function() {
  if (!window.web3AuthInstance) {
    throw new Error("Web3Auth not initialized");
  }
  
  try {
    const web3authProvider = await window.web3AuthInstance.connect();
    const user = await window.web3AuthInstance.getUserInfo();
    const privateKey = await window.web3AuthInstance.provider.request({
      method: "eth_private_key",
    });
    
    return {
      success: true,
      user: user,
      privateKey: privateKey,
    };
  } catch (error) {
    console.error("Web3Auth login failed:", error);
    return {
      success: false,
      error: error.message,
    };
  }
};

window.web3AuthLogout = async function() {
  if (!window.web3AuthInstance) {
    return { success: true };
  }
  
  try {
    await window.web3AuthInstance.logout();
    return { success: true };
  } catch (error) {
    console.error("Web3Auth logout failed:", error);
    return { success: false, error: error.message };
  }
};