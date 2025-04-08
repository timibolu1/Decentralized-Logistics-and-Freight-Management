// Mock implementation for Clarity blockchain testing
export function mockClarityBlockchain() {
	let state = {
		contracts: {},
		accounts: {},
		currentSender: '',
		blockHeight: 0
	};
	
	return {
		reset() {
			state = {
				contracts: {},
				accounts: {},
				currentSender: '',
				blockHeight: 0
			};
		},
		
		setCurrentSender(address) {
			state.currentSender = address;
		},
		
		creditAccount(address, amount) {
			if (!state.accounts[address]) {
				state.accounts[address] = { balance: 0 };
			}
			state.accounts[address].balance += amount;
		},
		
		getAccountBalance(address) {
			return state.accounts[address]?.balance || 0;
		},
		
		callPublic(method, args) {
			// This is a simplified mock - in a real implementation,
			// this would execute the actual Clarity code
			return {
				success: true,
				value: 1
			};
		},
		
		callReadOnly(method, args) {
			// Simplified mock for read-only functions
			if (method === 'is-carrier-verified') {
				return true;
			}
			
			if (method === 'get-carrier-details') {
				return {
					'company-name': 'Acme Logistics',
					'license-number': 'LIC123456',
					'verification-date': 123,
					'is-active': true
				};
			}
			
			if (method === 'get-shipment') {
				return {
					carrier: 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG',
					shipper: 'ST2JHG361ZXG51QTKY2NQCVBPPRRE2KZB1HR05NNC',
					origin: 'New York',
					destination: 'Los Angeles',
					'cargo-type': 'Electronics',
					weight: 5000,
					volume: 10,
					'booking-date': 123,
					'delivery-deadline': 100,
					status: 'booked'
				};
			}
			
			if (method === 'get-tracking-update') {
				return {
					location: args[0] === 1 ? 'Chicago' : 'Denver',
					timestamp: 123,
					status: 'in-transit',
					notes: 'Shipment passing through'
				};
			}
			
			if (method === 'get-update-count') {
				return 2;
			}
			
			if (method === 'get-escrow') {
				return {
					'shipment-id': args[0],
					amount: 500000,
					shipper: 'ST2JHG361ZXG51QTKY2NQCVBPPRRE2KZB1HR05NNC',
					carrier: 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG',
					status: 'completed',
					'created-at': 123,
					'completed-at': 456
				};
			}
			
			return null;
		},
		
		callContract(contract, method, args) {
			// Simplified mock for cross-contract calls
			if (contract === 'carrier-verification' && method === 'verify-carrier') {
				return { success: true };
			}
			
			if (contract === 'shipment-booking' && method === 'book-shipment') {
				return { success: true, value: 1 };
			}
			
			if (contract === 'shipment-booking' && method === 'get-shipment') {
				return {
					carrier: 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG',
					shipper: 'ST2JHG361ZXG51QTKY2NQCVBPPRRE2KZB1HR05NNC',
					status: 'in-transit'
				};
			}
			
			return { success: false, error: 1 };
		}
	};
}

export function mockClarityBitcoin() {
	return {
		// Bitcoin-related mock functions would go here
	};
}
