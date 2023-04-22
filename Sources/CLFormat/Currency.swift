//
//  Currency.swift
//  CLFormat
//
//  Created by Matthias Zenger on 12/03/2023.
//  Copyright © 2023 Matthias Zenger. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
//  implied. See the License for the specific language governing
//  permissions and limitations under the License.
//

import Foundation

/// 
/// Representation of currencies supporting the use of the `~$` directive.
/// CLFormat supports an extension of `~$` which allows for including currency
/// codes and currency symbols in the output. The representation of currencies
/// is based on ISO 4217.
/// 
/// Each currency object provides access to the following properties:
///   - Name of the currency (in English)
///   - Alphabetic currency code (e.g. USD, EUR, CHF)
///   - Numeric currency code (e.g. 840, 978, 756)
///   - Shortest currency symbol (e.g. $, €, £, ￥)
///   - Minor unit (number of digits to represent the next minor unit, e.g. cents)
/// 
public struct Currency: Hashable, Codable, CustomStringConvertible {
  
  /// Name of the currency in English.
  public let name: String
  
  /// Alphabetic currency code.
  public let alphabeticCode: String
  
  /// Numeric currency code.
  public let numericCode: UInt16
  
  /// Number of digits used by the next minor unit (e.g. cents).
  public let minorUnit: UInt8
  
  /// Shortest known currency symbol (e.g. $).
  public let currencySymbol: String?
  
  /// Internal constructor.
  private init(name: String,
               alphabeticCode: String,
               numericCode: UInt16,
               minorUnit: UInt8,
               currencySymbol: String?) {
    self.name = name
    self.alphabeticCode = alphabeticCode
    self.numericCode = numericCode
    self.minorUnit = minorUnit
    self.currencySymbol = currencySymbol
  }
  
  /// Create a currency value based on an alphabetic currency code.
  public init?(alphabeticCode: String) {
    if let currency = Currency.alphabeticMap[alphabeticCode] {
      self = currency
    } else {
      return nil
    }
  }
  
  /// Create a currency value based on a numeric currency code.
  public init?(numericCode: UInt16) {
    if let currency = Currency.numericMap[numericCode] {
      self = currency
    } else {
      return nil
    }
  }
  
  /// Create a currency value based on a numeric currency code.
  public init?(numericCode: Int) {
    self.init(numericCode: UInt16(numericCode))
  }
  
  /// Return a localized currency symbol for this currency in the given locale.
  public func currencySymbol(in locale: Locale? = nil) -> String? {
    if let locale = locale,
       let res = (locale as NSLocale).displayName(forKey: .currencySymbol,
                                                  value: self.alphabeticCode) {
      return res
    }
    return NSLocale(localeIdentifier: self.alphabeticCode).displayName(forKey: .currencySymbol,
                                                                       value: self.alphabeticCode)
  }
  
  /// Returns a description of this currency; this matches the alphabetic code of the currency.
  public var description: String {
    return self.alphabeticCode
  }
  
  public static let AFN = currency("Afghani", "AFN", 971, 2)
  public static let EUR = currency("Euro", "EUR", 978, 2)
  public static let ALL = currency("Lek", "ALL", 008, 2)
  public static let DZD = currency("Algerian Dinar", "DZD", 012, 2)
  public static let USD = currency("US Dollar", "USD", 840, 2)
  public static let AOA = currency("Kwanza", "AOA", 973, 2)
  public static let XCD = currency("East Caribbean Dollar", "XCD", 951, 2)
  public static let ARS = currency("Argentine Peso", "ARS", 032, 2)
  public static let AMD = currency("Armenian Dram", "AMD", 051, 2)
  public static let AWG = currency("Aruban Florin", "AWG", 533, 2)
  public static let AUD = currency("Australian Dollar", "AUD", 036, 2)
  public static let AZN = currency("Azerbaijan Manat", "AZN", 944, 2)
  public static let BSD = currency("Bahamian Dollar", "BSD", 044, 2)
  public static let BHD = currency("Bahraini Dinar", "BHD", 048, 3)
  public static let BDT = currency("Taka", "BDT", 050, 2)
  public static let BBD = currency("Barbados Dollar", "BBD", 052, 2)
  public static let BYN = currency("Belarusian Ruble", "BYN", 933, 2)
  public static let BZD = currency("Belize Dollar", "BZD", 084, 2)
  public static let XOF = currency("CFA Franc BCEAO", "XOF", 952, 0)
  public static let BMD = currency("Bermudian Dollar", "BMD", 060, 2)
  public static let INR = currency("Indian Rupee", "INR", 356, 2)
  public static let BTN = currency("Ngultrum", "BTN", 064, 2)
  public static let BOB = currency("Boliviano", "BOB", 068, 2)
  public static let BOV = currency("Mvdol", "BOV", 984, 2)
  public static let BAM = currency("Convertible Mark", "BAM", 977, 2)
  public static let BWP = currency("Pula", "BWP", 072, 2)
  public static let NOK = currency("Norwegian Krone", "NOK", 578, 2)
  public static let BRL = currency("Brazilian Real", "BRL", 986, 2)
  public static let BND = currency("Brunei Dollar", "BND", 096, 2)
  public static let BGN = currency("Bulgarian Lev", "BGN", 975, 2)
  public static let BIF = currency("Burundi Franc", "BIF", 108, 0)
  public static let CVE = currency("Cabo Verde Escudo", "CVE", 132, 2)
  public static let KHR = currency("Riel", "KHR", 116, 2)
  public static let XAF = currency("CFA Franc BEAC", "XAF", 950, 0)
  public static let CAD = currency("Canadian Dollar", "CAD", 124, 2)
  public static let KYD = currency("Cayman Islands Dollar", "KYD", 136, 2)
  public static let CLP = currency("Chilean Peso", "CLP", 152, 0)
  public static let CLF = currency("Unidad de Fomento", "CLF", 990, 4)
  public static let CNY = currency("Yuan Renminbi", "CNY", 156, 2)
  public static let COP = currency("Colombian Peso", "COP", 170, 2)
  public static let COU = currency("Unidad de Valor Real", "COU", 970, 2)
  public static let KMF = currency("Comorian Franc ", "KMF", 174, 0)
  public static let CDF = currency("Congolese Franc", "CDF", 976, 2)
  public static let NZD = currency("New Zealand Dollar", "NZD", 554, 2)
  public static let CRC = currency("Costa Rican Colon", "CRC", 188, 2)
  public static let CUP = currency("Cuban Peso", "CUP", 192, 2)
  public static let CUC = currency("Peso Convertible", "CUC", 931, 2)
  public static let ANG = currency("Netherlands Antillean Guilder", "ANG", 532, 2)
  public static let CZK = currency("Czech Koruna", "CZK", 203, 2)
  public static let DKK = currency("Danish Krone", "DKK", 208, 2)
  public static let DJF = currency("Djibouti Franc", "DJF", 262, 0)
  public static let DOP = currency("Dominican Peso", "DOP", 214, 2)
  public static let EGP = currency("Egyptian Pound", "EGP", 818, 2)
  public static let SVC = currency("El Salvador Colon", "SVC", 222, 2)
  public static let ERN = currency("Nakfa", "ERN", 232, 2)
  public static let SZL = currency("Lilangeni", "SZL", 748, 2)
  public static let ETB = currency("Ethiopian Birr", "ETB", 230, 2)
  public static let FKP = currency("Falkland Islands Pound", "FKP", 238, 2)
  public static let FJD = currency("Fiji Dollar", "FJD", 242, 2)
  public static let XPF = currency("CFP Franc", "XPF", 953, 0)
  public static let GMD = currency("Dalasi", "GMD", 270, 2)
  public static let GEL = currency("Lari", "GEL", 981, 2)
  public static let GHS = currency("Ghana Cedi", "GHS", 936, 2)
  public static let GIP = currency("Gibraltar Pound", "GIP", 292, 2)
  public static let GTQ = currency("Quetzal", "GTQ", 320, 2)
  public static let GBP = currency("Pound Sterling", "GBP", 826, 2)
  public static let GNF = currency("Guinean Franc", "GNF", 324, 0)
  public static let GYD = currency("Guyana Dollar", "GYD", 328, 2)
  public static let HTG = currency("Gourde", "HTG", 332, 2)
  public static let HNL = currency("Lempira", "HNL", 340, 2)
  public static let HKD = currency("Hong Kong Dollar", "HKD", 344, 2)
  public static let HUF = currency("Forint", "HUF", 348, 2)
  public static let ISK = currency("Iceland Krona", "ISK", 352, 0)
  public static let IDR = currency("Rupiah", "IDR", 360, 2)
  public static let IRR = currency("Iranian Rial", "IRR", 364, 2)
  public static let IQD = currency("Iraqi Dinar", "IQD", 368, 3)
  public static let ILS = currency("New Israeli Sheqel", "ILS", 376, 2)
  public static let JMD = currency("Jamaican Dollar", "JMD", 388, 2)
  public static let JPY = currency("Yen", "JPY", 392, 0)
  public static let JOD = currency("Jordanian Dinar", "JOD", 400, 3)
  public static let KZT = currency("Tenge", "KZT", 398, 2)
  public static let KES = currency("Kenyan Shilling", "KES", 404, 2)
  public static let KPW = currency("North Korean Won", "KPW", 408, 2)
  public static let KRW = currency("Won", "KRW", 410, 0)
  public static let KWD = currency("Kuwaiti Dinar", "KWD", 414, 3)
  public static let KGS = currency("Som", "KGS", 417, 2)
  public static let LAK = currency("Lao Kip", "LAK", 418, 2)
  public static let LBP = currency("Lebanese Pound", "LBP", 422, 2)
  public static let LSL = currency("Loti", "LSL", 426, 2)
  public static let ZAR = currency("Rand", "ZAR", 710, 2)
  public static let LRD = currency("Liberian Dollar", "LRD", 430, 2)
  public static let LYD = currency("Libyan Dinar", "LYD", 434, 3)
  public static let CHF = currency("Swiss Franc", "CHF", 756, 2)
  public static let MOP = currency("Pataca", "MOP", 446, 2)
  public static let MKD = currency("Denar", "MKD", 807, 2)
  public static let MGA = currency("Malagasy Ariary", "MGA", 969, 2)
  public static let MWK = currency("Malawi Kwacha", "MWK", 454, 2)
  public static let MYR = currency("Malaysian Ringgit", "MYR", 458, 2)
  public static let MVR = currency("Rufiyaa", "MVR", 462, 2)
  public static let MRU = currency("Ouguiya", "MRU", 929, 2)
  public static let MUR = currency("Mauritius Rupee", "MUR", 480, 2)
  public static let MXN = currency("Mexican Peso", "MXN", 484, 2)
  public static let MXV = currency("Mexican Unidad de Inversion (UDI)", "MXV", 979, 2)
  public static let MDL = currency("Moldovan Leu", "MDL", 498, 2)
  public static let MNT = currency("Tugrik", "MNT", 496, 2)
  public static let MAD = currency("Moroccan Dirham", "MAD", 504, 2)
  public static let MZN = currency("Mozambique Metical", "MZN", 943, 2)
  public static let MMK = currency("Kyat", "MMK", 104, 2)
  public static let NAD = currency("Namibia Dollar", "NAD", 516, 2)
  public static let NPR = currency("Nepalese Rupee", "NPR", 524, 2)
  public static let NIO = currency("Cordoba Oro", "NIO", 558, 2)
  public static let NGN = currency("Naira", "NGN", 566, 2)
  public static let OMR = currency("Rial Omani", "OMR", 512, 3)
  public static let PKR = currency("Pakistan Rupee", "PKR", 586, 2)
  public static let PAB = currency("Balboa", "PAB", 590, 2)
  public static let PGK = currency("Kina", "PGK", 598, 2)
  public static let PYG = currency("Guarani", "PYG", 600, 0)
  public static let PEN = currency("Sol", "PEN", 604, 2)
  public static let PHP = currency("Philippine Peso", "PHP", 608, 2)
  public static let PLN = currency("Zloty", "PLN", 985, 2)
  public static let QAR = currency("Qatari Rial", "QAR", 634, 2)
  public static let RON = currency("Romanian Leu", "RON", 946, 2)
  public static let RUB = currency("Russian Ruble", "RUB", 643, 2)
  public static let RWF = currency("Rwanda Franc", "RWF", 646, 0)
  public static let SHP = currency("Saint Helena Pound", "SHP", 654, 2)
  public static let WST = currency("Tala", "WST", 882, 2)
  public static let STN = currency("Dobra", "STN", 930, 2)
  public static let SAR = currency("Saudi Riyal", "SAR", 682, 2)
  public static let RSD = currency("Serbian Dinar", "RSD", 941, 2)
  public static let SCR = currency("Seychelles Rupee", "SCR", 690, 2)
  public static let SLL = currency("Leone", "SLL", 694, 2)
  public static let SLE = currency("Leone", "SLE", 925, 2)
  public static let SGD = currency("Singapore Dollar", "SGD", 702, 2)
  public static let SBD = currency("Solomon Islands Dollar", "SBD", 090, 2)
  public static let SOS = currency("Somali Shilling", "SOS", 706, 2)
  public static let SSP = currency("South Sudanese Pound", "SSP", 728, 2)
  public static let LKR = currency("Sri Lanka Rupee", "LKR", 144, 2)
  public static let SDG = currency("Sudanese Pound", "SDG", 938, 2)
  public static let SRD = currency("Surinam Dollar", "SRD", 968, 2)
  public static let SEK = currency("Swedish Krona", "SEK", 752, 2)
  public static let CHE = currency("WIR Euro", "CHE", 947, 2)
  public static let CHW = currency("WIR Franc", "CHW", 948, 2)
  public static let SYP = currency("Syrian Pound", "SYP", 760, 2)
  public static let TWD = currency("New Taiwan Dollar", "TWD", 901, 2)
  public static let TJS = currency("Somoni", "TJS", 972, 2)
  public static let TZS = currency("Tanzanian Shilling", "TZS", 834, 2)
  public static let THB = currency("Baht", "THB", 764, 2)
  public static let TOP = currency("Pa’anga", "TOP", 776, 2)
  public static let TTD = currency("Trinidad and Tobago Dollar", "TTD", 780, 2)
  public static let TND = currency("Tunisian Dinar", "TND", 788, 3)
  public static let TRY = currency("Turkish Lira", "TRY", 949, 2)
  public static let TMT = currency("Turkmenistan New Manat", "TMT", 934, 2)
  public static let UGX = currency("Uganda Shilling", "UGX", 800, 0)
  public static let UAH = currency("Hryvnia", "UAH", 980, 2)
  public static let AED = currency("UAE Dirham", "AED", 784, 2)
  public static let USN = currency("US Dollar (Next day)", "USN", 997, 2)
  public static let UYU = currency("Peso Uruguayo", "UYU", 858, 2)
  public static let UYI = currency("Uruguay Peso en Unidades Indexadas", "UYI", 940, 0)
  public static let UYW = currency("Unidad Previsional", "UYW", 927, 4)
  public static let UZS = currency("Uzbekistan Sum", "UZS", 860, 2)
  public static let VUV = currency("Vatu", "VUV", 548, 0)
  public static let VES = currency("Bolívar Soberano", "VES", 928, 2)
  public static let VED = currency("Bolívar Soberano", "VED", 926, 2)
  public static let VND = currency("Dong", "VND", 704, 0)
  public static let YER = currency("Yemeni Rial", "YER", 886, 2)
  public static let ZMW = currency("Zambian Kwacha", "ZMW", 967, 2)
  public static let ZWL = currency("Zimbabwe Dollar", "ZWL", 932, 2)
  
  private static let alphabeticMap: [String : Currency] = [
    Currency.AFN.alphabeticCode : Currency.AFN,
    Currency.EUR.alphabeticCode : Currency.EUR,
    Currency.ALL.alphabeticCode : Currency.ALL,
    Currency.DZD.alphabeticCode : Currency.DZD,
    Currency.USD.alphabeticCode : Currency.USD,
    Currency.AOA.alphabeticCode : Currency.AOA,
    Currency.XCD.alphabeticCode : Currency.XCD,
    Currency.ARS.alphabeticCode : Currency.ARS,
    Currency.AMD.alphabeticCode : Currency.AMD,
    Currency.AWG.alphabeticCode : Currency.AWG,
    Currency.AUD.alphabeticCode : Currency.AUD,
    Currency.AZN.alphabeticCode : Currency.AZN,
    Currency.BSD.alphabeticCode : Currency.BSD,
    Currency.BHD.alphabeticCode : Currency.BHD,
    Currency.BDT.alphabeticCode : Currency.BDT,
    Currency.BBD.alphabeticCode : Currency.BBD,
    Currency.BYN.alphabeticCode : Currency.BYN,
    Currency.BZD.alphabeticCode : Currency.BZD,
    Currency.XOF.alphabeticCode : Currency.XOF,
    Currency.BMD.alphabeticCode : Currency.BMD,
    Currency.INR.alphabeticCode : Currency.INR,
    Currency.BTN.alphabeticCode : Currency.BTN,
    Currency.BOB.alphabeticCode : Currency.BOB,
    Currency.BOV.alphabeticCode : Currency.BOV,
    Currency.BAM.alphabeticCode : Currency.BAM,
    Currency.BWP.alphabeticCode : Currency.BWP,
    Currency.NOK.alphabeticCode : Currency.NOK,
    Currency.BRL.alphabeticCode : Currency.BRL,
    Currency.BND.alphabeticCode : Currency.BND,
    Currency.BGN.alphabeticCode : Currency.BGN,
    Currency.BIF.alphabeticCode : Currency.BIF,
    Currency.CVE.alphabeticCode : Currency.CVE,
    Currency.KHR.alphabeticCode : Currency.KHR,
    Currency.XAF.alphabeticCode : Currency.XAF,
    Currency.CAD.alphabeticCode : Currency.CAD,
    Currency.KYD.alphabeticCode : Currency.KYD,
    Currency.CLP.alphabeticCode : Currency.CLP,
    Currency.CLF.alphabeticCode : Currency.CLF,
    Currency.CNY.alphabeticCode : Currency.CNY,
    Currency.COP.alphabeticCode : Currency.COP,
    Currency.COU.alphabeticCode : Currency.COU,
    Currency.KMF.alphabeticCode : Currency.KMF,
    Currency.CDF.alphabeticCode : Currency.CDF,
    Currency.NZD.alphabeticCode : Currency.NZD,
    Currency.CRC.alphabeticCode : Currency.CRC,
    Currency.CUP.alphabeticCode : Currency.CUP,
    Currency.CUC.alphabeticCode : Currency.CUC,
    Currency.ANG.alphabeticCode : Currency.ANG,
    Currency.CZK.alphabeticCode : Currency.CZK,
    Currency.DKK.alphabeticCode : Currency.DKK,
    Currency.DJF.alphabeticCode : Currency.DJF,
    Currency.DOP.alphabeticCode : Currency.DOP,
    Currency.EGP.alphabeticCode : Currency.EGP,
    Currency.SVC.alphabeticCode : Currency.SVC,
    Currency.ERN.alphabeticCode : Currency.ERN,
    Currency.SZL.alphabeticCode : Currency.SZL,
    Currency.ETB.alphabeticCode : Currency.ETB,
    Currency.FKP.alphabeticCode : Currency.FKP,
    Currency.FJD.alphabeticCode : Currency.FJD,
    Currency.XPF.alphabeticCode : Currency.XPF,
    Currency.GMD.alphabeticCode : Currency.GMD,
    Currency.GEL.alphabeticCode : Currency.GEL,
    Currency.GHS.alphabeticCode : Currency.GHS,
    Currency.GIP.alphabeticCode : Currency.GIP,
    Currency.GTQ.alphabeticCode : Currency.GTQ,
    Currency.GBP.alphabeticCode : Currency.GBP,
    Currency.GNF.alphabeticCode : Currency.GNF,
    Currency.GYD.alphabeticCode : Currency.GYD,
    Currency.HTG.alphabeticCode : Currency.HTG,
    Currency.HNL.alphabeticCode : Currency.HNL,
    Currency.HKD.alphabeticCode : Currency.HKD,
    Currency.HUF.alphabeticCode : Currency.HUF,
    Currency.ISK.alphabeticCode : Currency.ISK,
    Currency.IDR.alphabeticCode : Currency.IDR,
    Currency.IRR.alphabeticCode : Currency.IRR,
    Currency.IQD.alphabeticCode : Currency.IQD,
    Currency.ILS.alphabeticCode : Currency.ILS,
    Currency.JMD.alphabeticCode : Currency.JMD,
    Currency.JPY.alphabeticCode : Currency.JPY,
    Currency.JOD.alphabeticCode : Currency.JOD,
    Currency.KZT.alphabeticCode : Currency.KZT,
    Currency.KES.alphabeticCode : Currency.KES,
    Currency.KPW.alphabeticCode : Currency.KPW,
    Currency.KRW.alphabeticCode : Currency.KRW,
    Currency.KWD.alphabeticCode : Currency.KWD,
    Currency.KGS.alphabeticCode : Currency.KGS,
    Currency.LAK.alphabeticCode : Currency.LAK,
    Currency.LBP.alphabeticCode : Currency.LBP,
    Currency.LSL.alphabeticCode : Currency.LSL,
    Currency.ZAR.alphabeticCode : Currency.ZAR,
    Currency.LRD.alphabeticCode : Currency.LRD,
    Currency.LYD.alphabeticCode : Currency.LYD,
    Currency.CHF.alphabeticCode : Currency.CHF,
    Currency.MOP.alphabeticCode : Currency.MOP,
    Currency.MKD.alphabeticCode : Currency.MKD,
    Currency.MGA.alphabeticCode : Currency.MGA,
    Currency.MWK.alphabeticCode : Currency.MWK,
    Currency.MYR.alphabeticCode : Currency.MYR,
    Currency.MVR.alphabeticCode : Currency.MVR,
    Currency.MRU.alphabeticCode : Currency.MRU,
    Currency.MUR.alphabeticCode : Currency.MUR,
    Currency.MXN.alphabeticCode : Currency.MXN,
    Currency.MXV.alphabeticCode : Currency.MXV,
    Currency.MDL.alphabeticCode : Currency.MDL,
    Currency.MNT.alphabeticCode : Currency.MNT,
    Currency.MAD.alphabeticCode : Currency.MAD,
    Currency.MZN.alphabeticCode : Currency.MZN,
    Currency.MMK.alphabeticCode : Currency.MMK,
    Currency.NAD.alphabeticCode : Currency.NAD,
    Currency.NPR.alphabeticCode : Currency.NPR,
    Currency.NIO.alphabeticCode : Currency.NIO,
    Currency.NGN.alphabeticCode : Currency.NGN,
    Currency.OMR.alphabeticCode : Currency.OMR,
    Currency.PKR.alphabeticCode : Currency.PKR,
    Currency.PAB.alphabeticCode : Currency.PAB,
    Currency.PGK.alphabeticCode : Currency.PGK,
    Currency.PYG.alphabeticCode : Currency.PYG,
    Currency.PEN.alphabeticCode : Currency.PEN,
    Currency.PHP.alphabeticCode : Currency.PHP,
    Currency.PLN.alphabeticCode : Currency.PLN,
    Currency.QAR.alphabeticCode : Currency.QAR,
    Currency.RON.alphabeticCode : Currency.RON,
    Currency.RUB.alphabeticCode : Currency.RUB,
    Currency.RWF.alphabeticCode : Currency.RWF,
    Currency.SHP.alphabeticCode : Currency.SHP,
    Currency.WST.alphabeticCode : Currency.WST,
    Currency.STN.alphabeticCode : Currency.STN,
    Currency.SAR.alphabeticCode : Currency.SAR,
    Currency.RSD.alphabeticCode : Currency.RSD,
    Currency.SCR.alphabeticCode : Currency.SCR,
    Currency.SLL.alphabeticCode : Currency.SLL,
    Currency.SLE.alphabeticCode : Currency.SLE,
    Currency.SGD.alphabeticCode : Currency.SGD,
    Currency.SBD.alphabeticCode : Currency.SBD,
    Currency.SOS.alphabeticCode : Currency.SOS,
    Currency.SSP.alphabeticCode : Currency.SSP,
    Currency.LKR.alphabeticCode : Currency.LKR,
    Currency.SDG.alphabeticCode : Currency.SDG,
    Currency.SRD.alphabeticCode : Currency.SRD,
    Currency.SEK.alphabeticCode : Currency.SEK,
    Currency.CHE.alphabeticCode : Currency.CHE,
    Currency.CHW.alphabeticCode : Currency.CHW,
    Currency.SYP.alphabeticCode : Currency.SYP,
    Currency.TWD.alphabeticCode : Currency.TWD,
    Currency.TJS.alphabeticCode : Currency.TJS,
    Currency.TZS.alphabeticCode : Currency.TZS,
    Currency.THB.alphabeticCode : Currency.THB,
    Currency.TOP.alphabeticCode : Currency.TOP,
    Currency.TTD.alphabeticCode : Currency.TTD,
    Currency.TND.alphabeticCode : Currency.TND,
    Currency.TRY.alphabeticCode : Currency.TRY,
    Currency.TMT.alphabeticCode : Currency.TMT,
    Currency.UGX.alphabeticCode : Currency.UGX,
    Currency.UAH.alphabeticCode : Currency.UAH,
    Currency.AED.alphabeticCode : Currency.AED,
    Currency.USN.alphabeticCode : Currency.USN,
    Currency.UYU.alphabeticCode : Currency.UYU,
    Currency.UYI.alphabeticCode : Currency.UYI,
    Currency.UYW.alphabeticCode : Currency.UYW,
    Currency.UZS.alphabeticCode : Currency.UZS,
    Currency.VUV.alphabeticCode : Currency.VUV,
    Currency.VES.alphabeticCode : Currency.VES,
    Currency.VED.alphabeticCode : Currency.VED,
    Currency.VND.alphabeticCode : Currency.VND,
    Currency.YER.alphabeticCode : Currency.YER,
    Currency.ZMW.alphabeticCode : Currency.ZMW,
    Currency.ZWL.alphabeticCode : Currency.ZWL
  ]
  
  private static let numericMap: [UInt16 : Currency] = [
    Currency.AFN.numericCode : Currency.AFN,
    Currency.EUR.numericCode : Currency.EUR,
    Currency.ALL.numericCode : Currency.ALL,
    Currency.DZD.numericCode : Currency.DZD,
    Currency.USD.numericCode : Currency.USD,
    Currency.AOA.numericCode : Currency.AOA,
    Currency.XCD.numericCode : Currency.XCD,
    Currency.ARS.numericCode : Currency.ARS,
    Currency.AMD.numericCode : Currency.AMD,
    Currency.AWG.numericCode : Currency.AWG,
    Currency.AUD.numericCode : Currency.AUD,
    Currency.AZN.numericCode : Currency.AZN,
    Currency.BSD.numericCode : Currency.BSD,
    Currency.BHD.numericCode : Currency.BHD,
    Currency.BDT.numericCode : Currency.BDT,
    Currency.BBD.numericCode : Currency.BBD,
    Currency.BYN.numericCode : Currency.BYN,
    Currency.BZD.numericCode : Currency.BZD,
    Currency.XOF.numericCode : Currency.XOF,
    Currency.BMD.numericCode : Currency.BMD,
    Currency.INR.numericCode : Currency.INR,
    Currency.BTN.numericCode : Currency.BTN,
    Currency.BOB.numericCode : Currency.BOB,
    Currency.BOV.numericCode : Currency.BOV,
    Currency.BAM.numericCode : Currency.BAM,
    Currency.BWP.numericCode : Currency.BWP,
    Currency.NOK.numericCode : Currency.NOK,
    Currency.BRL.numericCode : Currency.BRL,
    Currency.BND.numericCode : Currency.BND,
    Currency.BGN.numericCode : Currency.BGN,
    Currency.BIF.numericCode : Currency.BIF,
    Currency.CVE.numericCode : Currency.CVE,
    Currency.KHR.numericCode : Currency.KHR,
    Currency.XAF.numericCode : Currency.XAF,
    Currency.CAD.numericCode : Currency.CAD,
    Currency.KYD.numericCode : Currency.KYD,
    Currency.CLP.numericCode : Currency.CLP,
    Currency.CLF.numericCode : Currency.CLF,
    Currency.CNY.numericCode : Currency.CNY,
    Currency.COP.numericCode : Currency.COP,
    Currency.COU.numericCode : Currency.COU,
    Currency.KMF.numericCode : Currency.KMF,
    Currency.CDF.numericCode : Currency.CDF,
    Currency.NZD.numericCode : Currency.NZD,
    Currency.CRC.numericCode : Currency.CRC,
    Currency.CUP.numericCode : Currency.CUP,
    Currency.CUC.numericCode : Currency.CUC,
    Currency.ANG.numericCode : Currency.ANG,
    Currency.CZK.numericCode : Currency.CZK,
    Currency.DKK.numericCode : Currency.DKK,
    Currency.DJF.numericCode : Currency.DJF,
    Currency.DOP.numericCode : Currency.DOP,
    Currency.EGP.numericCode : Currency.EGP,
    Currency.SVC.numericCode : Currency.SVC,
    Currency.ERN.numericCode : Currency.ERN,
    Currency.SZL.numericCode : Currency.SZL,
    Currency.ETB.numericCode : Currency.ETB,
    Currency.FKP.numericCode : Currency.FKP,
    Currency.FJD.numericCode : Currency.FJD,
    Currency.XPF.numericCode : Currency.XPF,
    Currency.GMD.numericCode : Currency.GMD,
    Currency.GEL.numericCode : Currency.GEL,
    Currency.GHS.numericCode : Currency.GHS,
    Currency.GIP.numericCode : Currency.GIP,
    Currency.GTQ.numericCode : Currency.GTQ,
    Currency.GBP.numericCode : Currency.GBP,
    Currency.GNF.numericCode : Currency.GNF,
    Currency.GYD.numericCode : Currency.GYD,
    Currency.HTG.numericCode : Currency.HTG,
    Currency.HNL.numericCode : Currency.HNL,
    Currency.HKD.numericCode : Currency.HKD,
    Currency.HUF.numericCode : Currency.HUF,
    Currency.ISK.numericCode : Currency.ISK,
    Currency.IDR.numericCode : Currency.IDR,
    Currency.IRR.numericCode : Currency.IRR,
    Currency.IQD.numericCode : Currency.IQD,
    Currency.ILS.numericCode : Currency.ILS,
    Currency.JMD.numericCode : Currency.JMD,
    Currency.JPY.numericCode : Currency.JPY,
    Currency.JOD.numericCode : Currency.JOD,
    Currency.KZT.numericCode : Currency.KZT,
    Currency.KES.numericCode : Currency.KES,
    Currency.KPW.numericCode : Currency.KPW,
    Currency.KRW.numericCode : Currency.KRW,
    Currency.KWD.numericCode : Currency.KWD,
    Currency.KGS.numericCode : Currency.KGS,
    Currency.LAK.numericCode : Currency.LAK,
    Currency.LBP.numericCode : Currency.LBP,
    Currency.LSL.numericCode : Currency.LSL,
    Currency.ZAR.numericCode : Currency.ZAR,
    Currency.LRD.numericCode : Currency.LRD,
    Currency.LYD.numericCode : Currency.LYD,
    Currency.CHF.numericCode : Currency.CHF,
    Currency.MOP.numericCode : Currency.MOP,
    Currency.MKD.numericCode : Currency.MKD,
    Currency.MGA.numericCode : Currency.MGA,
    Currency.MWK.numericCode : Currency.MWK,
    Currency.MYR.numericCode : Currency.MYR,
    Currency.MVR.numericCode : Currency.MVR,
    Currency.MRU.numericCode : Currency.MRU,
    Currency.MUR.numericCode : Currency.MUR,
    Currency.MXN.numericCode : Currency.MXN,
    Currency.MXV.numericCode : Currency.MXV,
    Currency.MDL.numericCode : Currency.MDL,
    Currency.MNT.numericCode : Currency.MNT,
    Currency.MAD.numericCode : Currency.MAD,
    Currency.MZN.numericCode : Currency.MZN,
    Currency.MMK.numericCode : Currency.MMK,
    Currency.NAD.numericCode : Currency.NAD,
    Currency.NPR.numericCode : Currency.NPR,
    Currency.NIO.numericCode : Currency.NIO,
    Currency.NGN.numericCode : Currency.NGN,
    Currency.OMR.numericCode : Currency.OMR,
    Currency.PKR.numericCode : Currency.PKR,
    Currency.PAB.numericCode : Currency.PAB,
    Currency.PGK.numericCode : Currency.PGK,
    Currency.PYG.numericCode : Currency.PYG,
    Currency.PEN.numericCode : Currency.PEN,
    Currency.PHP.numericCode : Currency.PHP,
    Currency.PLN.numericCode : Currency.PLN,
    Currency.QAR.numericCode : Currency.QAR,
    Currency.RON.numericCode : Currency.RON,
    Currency.RUB.numericCode : Currency.RUB,
    Currency.RWF.numericCode : Currency.RWF,
    Currency.SHP.numericCode : Currency.SHP,
    Currency.WST.numericCode : Currency.WST,
    Currency.STN.numericCode : Currency.STN,
    Currency.SAR.numericCode : Currency.SAR,
    Currency.RSD.numericCode : Currency.RSD,
    Currency.SCR.numericCode : Currency.SCR,
    Currency.SLL.numericCode : Currency.SLL,
    Currency.SLE.numericCode : Currency.SLE,
    Currency.SGD.numericCode : Currency.SGD,
    Currency.SBD.numericCode : Currency.SBD,
    Currency.SOS.numericCode : Currency.SOS,
    Currency.SSP.numericCode : Currency.SSP,
    Currency.LKR.numericCode : Currency.LKR,
    Currency.SDG.numericCode : Currency.SDG,
    Currency.SRD.numericCode : Currency.SRD,
    Currency.SEK.numericCode : Currency.SEK,
    Currency.CHE.numericCode : Currency.CHE,
    Currency.CHW.numericCode : Currency.CHW,
    Currency.SYP.numericCode : Currency.SYP,
    Currency.TWD.numericCode : Currency.TWD,
    Currency.TJS.numericCode : Currency.TJS,
    Currency.TZS.numericCode : Currency.TZS,
    Currency.THB.numericCode : Currency.THB,
    Currency.TOP.numericCode : Currency.TOP,
    Currency.TTD.numericCode : Currency.TTD,
    Currency.TND.numericCode : Currency.TND,
    Currency.TRY.numericCode : Currency.TRY,
    Currency.TMT.numericCode : Currency.TMT,
    Currency.UGX.numericCode : Currency.UGX,
    Currency.UAH.numericCode : Currency.UAH,
    Currency.AED.numericCode : Currency.AED,
    Currency.USN.numericCode : Currency.USN,
    Currency.UYU.numericCode : Currency.UYU,
    Currency.UYI.numericCode : Currency.UYI,
    Currency.UYW.numericCode : Currency.UYW,
    Currency.UZS.numericCode : Currency.UZS,
    Currency.VUV.numericCode : Currency.VUV,
    Currency.VES.numericCode : Currency.VES,
    Currency.VED.numericCode : Currency.VED,
    Currency.VND.numericCode : Currency.VND,
    Currency.YER.numericCode : Currency.YER,
    Currency.ZMW.numericCode : Currency.ZMW,
    Currency.ZWL.numericCode : Currency.ZWL
  ]
  
  private static func currency(_ name: String,
                               _ alpha: String,
                               _ num: UInt16,
                               _ minor: UInt8) -> Currency {
    return Currency(name: name,
                    alphabeticCode: alpha,
                    numericCode: num,
                    minorUnit: minor,
                    currencySymbol: Currency.currencySymbol(from: alpha))
  }
  
  private static func currencySymbol(from code: String) -> String? {
    var res: String? = nil
    let locales = NSLocale.availableLocaleIdentifiers
    for localeid in locales {
      let locale = Locale(identifier: localeid as String)
      if let currencyCode = locale.currencyCode,
         currencyCode == code,
         let currencySymbol = locale.currencySymbol {
        let count = currencySymbol.count
        if count == 1 {
          return currencySymbol
        } else if count < (res?.count ?? Int.max) {
          res = currencySymbol
        }
      }
    }
    return res
  }
}

