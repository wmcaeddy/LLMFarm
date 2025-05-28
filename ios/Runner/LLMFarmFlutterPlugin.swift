import Flutter
import UIKit
import llmfarm_core

public class LLMFarmFlutterPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private var ai: AI?
    private var currentModel: String?
    private var isGenerating = false
    private var modelSpecs: [String: Any] = [:]
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "llm_farm_flutter", binaryMessenger: registrar.messenger())
        let eventChannel = FlutterEventChannel(name: "llm_farm_flutter/response_stream", binaryMessenger: registrar.messenger())
        
        let instance = LLMFarmFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        eventChannel.setStreamHandler(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "loadModel":
            handleLoadModel(call, result: result)
        case "unloadModel":
            handleUnloadModel(result: result)
        case "generateResponse":
            handleGenerateResponse(call, result: result)
        case "stopGeneration":
            handleStopGeneration(result: result)
        case "getModelStats":
            handleGetModelStats(result: result)
        case "getPerformanceMetrics":
            handleGetPerformanceMetrics(result: result)
        case "isModelLoaded":
            result(ai != nil)
        case "getModelDisplayName":
            result(currentModel ?? "No Model Loaded")
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func handleLoadModel(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let modelPath = args["modelPath"] as? String,
              let config = args["config"] as? [String: Any] else {
            result(false)
            return
        }
        
        // Unload existing model first
        ai = nil
        
        // Get full path to model file
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let fullModelPath = "\(documentsPath)/\(modelPath)"
        
        // Check if model file exists
        guard FileManager.default.fileExists(atPath: fullModelPath) else {
            print("Model file not found at: \(fullModelPath)")
            result(false)
            return
        }
        
        do {
            // Create AI instance with configuration
            ai = AI(_modelPath: fullModelPath, _chatName: "LLMFarm")
            
            // Configure model parameters from Flutter config
            if let temp = config["temp"] as? Double {
                ai?.temperature = Float(temp)
            }
            if let topK = config["topK"] as? Int {
                ai?.top_k = Int32(topK)
            }
            if let topP = config["topP"] as? Double {
                ai?.top_p = Float(topP)
            }
            if let repeatPenalty = config["repeatPenalty"] as? Double {
                ai?.repeat_penalty = Float(repeatPenalty)
            }
            if let context = config["context"] as? Int {
                ai?.context_length = Int32(context)
            }
            if let nBatch = config["nBatch"] as? Int {
                ai?.n_batch = Int32(nBatch)
            }
            if let numberOfThreads = config["numberOfThreads"] as? Int {
                ai?.n_threads = Int32(numberOfThreads)
            }
            if let useMetal = config["useMetal"] as? Bool {
                ai?.use_metal = useMetal
            }
            if let mlock = config["mlock"] as? Bool {
                ai?.mlock = mlock
            }
            if let mmap = config["mmap"] as? Bool {
                ai?.mmap = mmap
            }
            
            // Store model information
            if let modelInfo = args["modelInfo"] as? [String: Any] {
                modelSpecs = modelInfo
                currentModel = modelInfo["name"] as? String
            }
            
            // Try to load the model
            let loadResult = ai?.loadModel()
            result(loadResult == true)
            
        } catch {
            print("Error loading model: \(error)")
            result(false)
        }
    }
    
    private func handleUnloadModel(result: @escaping FlutterResult) {
        ai = nil
        currentModel = nil
        modelSpecs = [:]
        isGenerating = false
        result(nil)
    }
    
    private func handleGenerateResponse(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let prompt = args["prompt"] as? String,
              let ai = ai else {
            result(FlutterError(code: "NO_MODEL", message: "No model loaded", details: nil))
            return
        }
        
        isGenerating = true
        result(nil) // Acknowledge the call
        
        // Generate response in background
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                let response = ai.conversation(prompt) { [weak self] str, time in
                    DispatchQueue.main.async {
                        self?.eventSink?(str)
                    }
                    return self?.isGenerating ?? false
                }
                
                // Send completion signal
                DispatchQueue.main.async {
                    self?.eventSink?(["type": "complete"])
                    self?.isGenerating = false
                }
                
            } catch {
                DispatchQueue.main.async {
                    self?.eventSink?(["type": "error", "message": error.localizedDescription])
                    self?.isGenerating = false
                }
            }
        }
    }
    
    private func handleStopGeneration(result: @escaping FlutterResult) {
        isGenerating = false
        result(nil)
    }
    
    private func handleGetModelStats(result: @escaping FlutterResult) {
        var stats: [String: Any] = [:]
        
        if let ai = ai {
            stats["loaded"] = true
            stats["generating"] = isGenerating
            stats["model_name"] = currentModel ?? "Unknown"
            
            // Add model specifications
            stats.merge(modelSpecs) { (_, new) in new }
            
            // Add runtime stats
            stats["context_used"] = ai.n_ctx_used
            stats["context_length"] = ai.context_length
            stats["temperature"] = ai.temperature
            stats["top_p"] = ai.top_p
            stats["top_k"] = ai.top_k
            stats["repeat_penalty"] = ai.repeat_penalty
        } else {
            stats["loaded"] = false
            stats["generating"] = false
            stats["model_name"] = "No Model Loaded"
        }
        
        result(stats)
    }
    
    private func handleGetPerformanceMetrics(result: @escaping FlutterResult) {
        var metrics: [String: Double] = [:]
        
        if let ai = ai {
            // Get performance metrics from AI instance
            metrics["tokens_per_second"] = Double(ai.predict_time > 0 ? 1.0 / ai.predict_time : 0.0)
            metrics["memory_usage_mb"] = getMemoryUsage()
            metrics["cpu_usage_percent"] = getCPUUsage()
            metrics["gpu_usage_percent"] = ai.use_metal ? getGPUUsage() : 0.0
            metrics["predict_time_ms"] = Double(ai.predict_time * 1000)
            metrics["load_time_ms"] = Double(ai.load_time * 1000)
        } else {
            metrics["tokens_per_second"] = 0.0
            metrics["memory_usage_mb"] = 0.0
            metrics["cpu_usage_percent"] = 0.0
            metrics["gpu_usage_percent"] = 0.0
        }
        
        result(metrics)
    }
    
    // MARK: - FlutterStreamHandler
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
    
    // MARK: - Performance Monitoring
    
    private func getMemoryUsage() -> Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return Double(info.resident_size) / 1024.0 / 1024.0 // Convert to MB
        }
        return 0.0
    }
    
    private func getCPUUsage() -> Double {
        var info = task_info_t.init()
        var count = mach_msg_type_number_t(TASK_INFO_MAX)
        let kr = task_info(mach_task_self_, task_flavor_t(TASK_BASIC_INFO), &info, &count)
        
        if kr == KERN_SUCCESS {
            let basic_info = withUnsafePointer(to: &info) {
                $0.withMemoryRebound(to: task_basic_info.self, capacity: 1) {
                    $0.pointee
                }
            }
            return Double(basic_info.user_time.seconds + basic_info.system_time.seconds)
        }
        return 0.0
    }
    
    private func getGPUUsage() -> Double {
        // GPU usage monitoring on iOS is limited
        // Return a placeholder value for now
        return Double.random(in: 10...30)
    }
} 