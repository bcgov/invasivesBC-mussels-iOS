//
//  ApplicationLogger.swift
//  CipherCloudCoreLib
//
//  Created by Pushan Mitra on 24/02/16.
//  Copyright © 2016 CipherCloud. All rights reserved.
//

import Foundation


public typealias GetLogsCallback = (_ logs:[String : NSData]?) -> Void

public let LoggerCloseFlagKey: String = "ApplicationLogger.Closed"

let ReadLoggerFlag = { () -> Any? in
    return UserDefaults.standard.object(forKey: LoggerCloseFlagKey)
}

let WriteReaderFlag = {(_ value: Any) in
    UserDefaults.standard.set(value, forKey:LoggerCloseFlagKey);
}

let dateFormatter: DateFormatter = {
	let df: DateFormatter = DateFormatter();
	df.setLocalizedDateFormatFromTemplate(DataSource().timeFormat)
	df.locale = NSLocale.current
	return df
}()

func CurrentDataString() -> String {
	let str: String = dateFormatter.string(from: NSDate() as Date)
    let newStr = str.replacingOccurrences(of: ",", with: " ")
	return newStr
}

func createLogHeader(_ file: String, _ function: String, _ line: Int) -> String {
	return "\(file):\(function):\(line)"
}

func StackTrace () -> String {
	let trace: [String] = Thread.callStackSymbols
	var result: String = ""
	if trace.count > 2 {
		for i in 0...(trace.count - 2) {
			result.append("\(trace[i]) > ")
		}
		result.append(" : [END]")
	}
	else {
		result = trace[0]
	}
	
	return result
}

public protocol LoggerDataSource: NSObjectProtocol {
    var csvLogFileName: String { get }
    var logFileName: String { get }
    var maxSize: Int {get}
    var appNamePrefix: String {get}
    var timeFormat: String {get}
}

var globalDataSource: LoggerDataSource?


class DefaultDataSouce: NSObject, LoggerDataSource {
    var csvLogFileName: String = "app_logger.csv"
    var logFileName: String = "app_logger.txt"
    var maxSize: Int = 1024 * 1024 * 1
    var appNamePrefix: String = "LOGGER"
    var timeFormat: String = "dd-MMM-yy HH:mm:ss"
}

func LoggerSetDataSource(_ source: LoggerDataSource) {
    globalDataSource = source
}

func DataSource() -> LoggerDataSource {
    if let s: LoggerDataSource = globalDataSource {
        return s
    } else {
        return DefaultDataSouce()
    }
}




public func DebugLog(_ items: Any...,file: NSString = #file,line: Int = #line,function: String = #function) {
#if DEBUG
	let fileTrim = file.lastPathComponent;
	let loc = createLogHeader(fileTrim, function, line)
	var messageTemp: String = ""
	if items.count == 1 {
		messageTemp = "\(items[0])"
	}
	else {
		messageTemp = "\(items)"
	}
	
	let message: String = messageTemp.trimmingCharacters(in: .newlines)
	ApplicationLogger.defalutLogger.log(loc, .Debug, CurrentDataString(), message, nil)
#endif
}

public func InfoLog(_ items: Any...,file: NSString = #file, line: Int = #line, function: String = #function) {
    let fileTrim = file.lastPathComponent;
    let loc = createLogHeader(fileTrim, function, line)
    var messageTemp: String = ""
    if items.count == 1 {
        messageTemp = "\(items[0])"
    }
    else {
        messageTemp = "\(items)"
    }
    
    let message: String = messageTemp.trimmingCharacters(in: .newlines)
	ApplicationLogger.defalutLogger.crashLog(loc, .Info, CurrentDataString(), message, nil)
}

public func ErrorLog (_ items: Any...,file: NSString = #file,line: Int = #line,function: String = #function) {
    let fileTrim = file.lastPathComponent;
    let loc = createLogHeader(fileTrim, function, line)
    var messageTemp: String = ""
    if items.count == 1 {
        messageTemp = "\(items[0])"
    }
    else {
        messageTemp = "\(items)"
    }
    
    let message: String = messageTemp.trimmingCharacters(in: .newlines)
	ApplicationLogger.defalutLogger.log(loc, .Error, CurrentDataString(), message, nil)
}

public func CrashLog (_ items: Any..., file: NSString = #file, line: Int = #line, function: String = #function) {
    let fileTrim = file.lastPathComponent;
    let loc = createLogHeader(fileTrim, function, line)
    var messageTemp: String = ""
    if items.count == 1 {
        messageTemp = "\(items[0])"
    }
    else {
        messageTemp = "\(items)"
    }
    
    let message: String = messageTemp.trimmingCharacters(in: .newlines)
	ApplicationLogger.defalutLogger.log(loc, .Crash, CurrentDataString(), message, StackTrace())
}

public struct LogStatic {
	public static let LogFileName = "applicationLog"
	public static let LogCloseFlag = "CC.Logger.LogClosed"
	
	public static let  MaxLogFileSize: Int = 1024 * 1024 * 1 // 10MB
	
	public static let KeepLogEntryCount = 500
}


func DocumentDir() -> String {
	let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory,
		.userDomainMask, true)
	
	let docsDir: String = dirPaths[0]
	return docsDir
}

public enum LogType: String {
	case Error, Debug, Info, Crash
}

public protocol Logger : NSObjectProtocol {
	func log(_ location: String,_ type: LogType,_ dateStr: String,_ message: String,_ stackTrace: String?) -> Void
}


public class BaseLogger: NSObject, Logger {
	public func log(_ location: String,_ type: LogType,_ dateStr: String,_ message: String,_ stackTrace: String?) -> Void {
	
	}
}

@objc(LoggerDelegate)
public protocol LoggerDelegate: NSObjectProtocol {
	@objc optional func applicationLoggerDidLog(logger: AnyObject,_ type: String,_ dateStr: String,_ message: String) -> Void
}


public class FileLogger: BaseLogger {
	let file: CCFileHandle = CCFileHandle()
	var fileName: String?
	var filePath: NSString?
	var queue: OperationQueue?
	var canLog: Bool {
		return self.file.canLog()
	}
	var separator: String? = nil
	
	init(_ fileName: String) {
		self.fileName = fileName
		super.init()
	}
	
	
	func cleanOldLogs() {
		var sep: String = "\n"
		if self.separator != nil {
			sep = self.separator!
		}
		
		do {
			// Reading all entry
			let logString: String = try String(contentsOfFile: self.filePath! as String, encoding: String.Encoding.utf8)
			let allLogs: [String] = logString.components(separatedBy: sep)
			
			// Keep last 1000 entry
			var keepLogs: [String] = [String]()
			var keepSize: Int = LogStatic.KeepLogEntryCount
			if (keepSize + 1) > allLogs.count {
				// Keep Last 100
				if allLogs.count > 100 {
					keepSize = 99
				}
				else {
					// Keep 10
					keepSize = 10
				}
			}
			let stratIndex: Int = allLogs.count - keepSize
			let endIndex: Int = allLogs.count - 1
			keepLogs = Array(allLogs[stratIndex...endIndex])
			var newLog: String = String()
			for str in keepLogs {
				newLog.append(str)
				newLog.append(sep)
			}
			
			try newLog.write(toFile: self.filePath! as String, atomically: true, encoding: String.Encoding.utf8)
			
		}
		catch (let exp) {
			DebugLog("File \(String(describing: self.fileName)) Read/write exp :\(exp)")
		}
	}
	
	public func start() {
		if let fileName = self.fileName {
			let docDir: NSString = DocumentDir() as NSString
			let finalPath: String = docDir.appendingPathComponent(fileName)
			let fileManager: FileManager = FileManager.default
			if fileManager.fileExists(atPath: finalPath) {
				do {
					self.filePath = finalPath as NSString
					let attributes: [FileAttributeKey : Any] = try fileManager.attributesOfItem(atPath: finalPath)
					
					print("SIZE : \(fileName):\(String(describing: attributes[FileAttributeKey.size]))")
					
					if let fileSize: Int = attributes[FileAttributeKey.size] as? Int {
						print("\(fileName) : File size : \(fileSize)")
						if fileSize > DataSource().maxSize {
							// Delete log file.
							//try fileManager.removeItemAtPath(finalPath)
							self.cleanOldLogs()
						}
					}
					
				}
				catch (let exp){
					print("FILELOGGER: ERROR: LOG FILE(\(fileName)) CHECK EXCEPTION \(exp)")
				}
				
			}
			
			// Open The file
			if self.file.open(finalPath) {
				self.filePath = finalPath as NSString
				
				// Excluding log file from backup
                do {
                    var url: URL = URL(fileURLWithPath: finalPath)
                    var resourceValues = URLResourceValues()
                    resourceValues.isExcludedFromBackup = true
                    try url.setResourceValues(resourceValues)
                } catch (let excp) {
                    print("FILELOGGER: ERROR: Error while adding file from backing up FILE(\(fileName)) CHECK EXCEPTION \(excp)")
                }
			}
			else {
				print("FILELOGGER: FILE OPEN ERROR")
			}
		}
	}
	
	public func stop () {
		self.file.close()
		self.filePath = nil
	}
	
	/*public func removeLogFile() {
		self.file.close()
		if let path: NSString = self.filePath {
			do {
				try NSFileManager.defaultManager().removeItemAtPath(path as String)
			}
			catch (let error) {
				print("FILE LOGER : \(self.fileName) : Remove Excp:\(error)")
			}
		}
	}*/
	
	override public func log(_ location: String,_ type: LogType,_ dateStr: String,_ message: String,_ stackTrace: String?) {
		if self.canLog {
			
			if let queue = self.queue {
				queue.addOperation({ () -> Void in
					let printStr: String = "\(type.rawValue):[\(dateStr)]:{\(location)}:\(message)"
					self.file.print(printStr)
					if let st: String = stackTrace {
                        self.file.print("\n ** [STACK TRACE] ** \n")
						self.file.print(st)
                        self.file.print("** [END: STACK TRACE] ** \n")
					}
					if let sep: String = self.separator {
						self.file.print(sep)
					}
				})
			}
			else {
				DispatchQueue.main.async() { () -> Void in
					let printStr: String = "\(type.rawValue):[\(dateStr)]:{\(location)}:\(message)"
					self.file.print(printStr)
					if let st: String = stackTrace {
						self.file.print(st)
					}
					if let sep: String = self.separator {
						self.file.print(sep)
					}
				}
			}
			
		}
	}
	
	public func syncLog(location: NSString,_ type: LogType,_ dateStr: String,_ message: String,_ stackTrace: String?)
	{
		if self.canLog {
			let printStr: String = "\(type.rawValue):[\(dateStr)]:{\(location)}:\(message)"
			self.file.print(printStr)
			if let st: String = stackTrace {
				self.file.print(st)
			}
			if let sep: String = self.separator {
				self.file.print(sep)
			}
		}
	}
	
}

public class CSVLogger: FileLogger {
	
	
	override public func log(_ location: String,_ type: LogType,_ dateStr: String,_ message: String,_ stackTrace: String?) {
		if self.canLog {
			if let queue = self.queue {
				queue.addOperation({ () -> Void in
					let printStr: String = "\(type.rawValue),[\(dateStr)],\(location),\(message)"
					self.file.print(printStr)
				})
			}
			else {
				DispatchQueue.main.async() { () -> Void in
					let printStr: String = "\(type.rawValue),[\(dateStr)],\(location),\(message)"
					self.file.print(printStr)
				}
			}
			
		}
	}
	
	public func printHeader() {
		self.file.print("Type,Time,Location,Message")
	}
}

public class ConsoleLogger: BaseLogger {
	override public func log(_ location: String, _ type: LogType, _ dateStr: String, _ message: String, _ stackTrace: String?) {
		print("\(DataSource().appNamePrefix):\(type.rawValue):[\(dateStr)]:[\(location)]: \(message)")
		/*if let st: String = stackTrace {
			if type != LogType.Debug {
				print(st)
			}
		}*/
		print("-----------------------------------------------------------------------")
	}
}


public class ApplicationLogger: BaseLogger {
	public static let defalutLogger: ApplicationLogger = ApplicationLogger()
	
	public var delegate: LoggerDelegate?
	
	var csvLogger: CSVLogger = CSVLogger(DataSource().csvLogFileName)
	var fileLogger: FileLogger = FileLogger(DataSource().logFileName)
	var console: ConsoleLogger = ConsoleLogger()
	
	var started: Bool = false
	var logQueue: OperationQueue = OperationQueue()
	
	public override init() {
		self.started = true
		super.init()
		self.fileLogger.queue = self.logQueue
		self.csvLogger.queue = self.logQueue
		self.fileLogger.separator = "---------------------------------------------\n"
	}
	
	var applicationVersion: String {
		if let dict: [String : AnyObject] = Bundle.main.infoDictionary as [String : AnyObject]? {
			if let build: String = dict["CFBundleVersion"] as? String {
				if let ver: String = dict["CFBundleShortVersionString"] as? String {
					return "v" + ver + "(" + build + ")"
				}
				return  "v" + build
			}
		}
		return "1.0"
	}
	
	public func start() {
		
		self.logQueue.addOperation { () -> Void in
			self.csvLogger.start()
			self.fileLogger.start()
			
			self.logQueue.addOperation({ () -> Void in
				self.started = true
				
                
                if let closed: Bool = ReadLoggerFlag() as? Bool {
                    if !closed {
                        InfoLog("Last time Application Termmination was unsuccessful!!!!")
                    }
                } else {
                    InfoLog("Application start for first time or first time afte cache clear or this version")
                }
                WriteReaderFlag(false);
				InfoLog("Application start logging: \(self.applicationVersion): 0")
			})
		}
	}
	
	
	
	public func stop() {
		self.logQueue.cancelAllOperations()
		self.csvLogger.stop()
		self.fileLogger.stop()
		self.started = false
        WriteReaderFlag(true);
	}
    
    public func logsURLs() -> [URL] {
        var urls: [URL] = [URL]()
        if let filePath: String = self.fileLogger.filePath as String? {
            let url1: URL = URL(fileURLWithPath: filePath)
            urls.append(url1)
        }
        if let filePath: String = self.csvLogger.filePath as String?  {
            let url2: URL = URL(fileURLWithPath: filePath)
            urls.append(url2)
        }
        return urls
    }
	
	public func getLogs(callback: @escaping GetLogsCallback) {
		self.logQueue.addOperation { () -> Void in
			var results: [String : NSData] = [String : NSData]()
			
			if let csvPath: String = self.csvLogger.filePath as String? {
				if let data: NSData = NSData(contentsOfFile: csvPath) {
					results[self.csvLogger.fileName!] = data
				}
			}
			
			if let filePath: String = self.fileLogger.filePath as String? {
				if let data: NSData = NSData(contentsOfFile: filePath) {
					results[self.fileLogger.fileName!] = data
				}
			}
			
			callback(results)
		}
	}
	
	override public func log(_ location: String, _ type: LogType, _ dateStr: String, _ message: String, _ stackTrace: String?) {
		
		if type == LogType.Error || type == LogType.Info {
			self.csvLogger.log(location, type, dateStr, message, nil)
			self.fileLogger.log(location, type, dateStr, message, stackTrace)
			/*if let delegate: LoggerDelegate = self.delegate {
				delegate.applicationLoggerDidLog?(self, type.rawValue, dateStr, message)
			}*/
		}
		
		self.console.log(location, type, dateStr, message, stackTrace)
		
	}
	
	public func crashLog(_ location: String, _ type: LogType, _ dateStr: String, _ message: String, _ stackTrace: String?) {
		self.csvLogger.log(location, type, dateStr, message, nil)
		self.fileLogger.log(location, type, dateStr, message, stackTrace)
		self.console.log(location, type, dateStr, message, stackTrace)
	}
}
