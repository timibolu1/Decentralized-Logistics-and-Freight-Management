import { describe, it, expect, beforeEach } from 'vitest';
import { mockClarityBitcoin, mockClarityBlockchain } from './mocks';

// Mock the Clarity environment
const blockchain = mockClarityBlockchain();
const bitcoin = mockClarityBitcoin();

describe('Carrier Verification Contract', () => {
  const admin = 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM';
  const carrier1 = 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG';
  const carrier2 = 'ST2JHG361ZXG51QTKY2NQCVBPPRRE2KZB1HR05NNC';
  
  beforeEach(() => {
    // Reset blockchain state
    blockchain.reset();
    
    // Set current sender as admin
    blockchain.setCurrentSender(admin);
  });
  
  it('should verify a carrier successfully', () => {
    const result = blockchain.callPublic('verify-carrier', [
      carrier1,
      'Acme Logistics',
      'LIC123456'
    ]);
    
    expect(result.success).toBe(true);
    
    const isVerified = blockchain.callReadOnly('is-carrier-verified', [carrier1]);
    expect(isVerified).toBe(true);
  });
  
  it('should get carrier details', () => {
    blockchain.callPublic('verify-carrier', [
      carrier1,
      'Acme Logistics',
      'LIC123456'
    ]);
    
    const details = blockchain.callReadOnly('get-carrier-details', [carrier1]);
    
    expect(details).toEqual({
      'company-name': 'Acme Logistics',
      'license-number': 'LIC123456',
      'verification-date': expect.any(Number),
      'is-active': true
    });
  });
});
