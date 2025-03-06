// @generated
// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: worker.proto

package com.facebook.buck.worker.model;

@javax.annotation.Generated(value="protoc", comments="annotations:WorkerProto.java.pb.meta")
public final class WorkerProto {
  private WorkerProto() {}
  public static void registerAllExtensions(
      com.google.protobuf.ExtensionRegistryLite registry) {
  }

  public static void registerAllExtensions(
      com.google.protobuf.ExtensionRegistry registry) {
    registerAllExtensions(
        (com.google.protobuf.ExtensionRegistryLite) registry);
  }
  static final com.google.protobuf.Descriptors.Descriptor
    internal_static_worker_ExecuteCommand_descriptor;
  static final 
    com.google.protobuf.GeneratedMessageV3.FieldAccessorTable
      internal_static_worker_ExecuteCommand_fieldAccessorTable;
  static final com.google.protobuf.Descriptors.Descriptor
    internal_static_worker_ExecuteCommand_EnvironmentEntry_descriptor;
  static final 
    com.google.protobuf.GeneratedMessageV3.FieldAccessorTable
      internal_static_worker_ExecuteCommand_EnvironmentEntry_fieldAccessorTable;
  static final com.google.protobuf.Descriptors.Descriptor
    internal_static_worker_ExecuteResponse_descriptor;
  static final 
    com.google.protobuf.GeneratedMessageV3.FieldAccessorTable
      internal_static_worker_ExecuteResponse_fieldAccessorTable;
  static final com.google.protobuf.Descriptors.Descriptor
    internal_static_worker_ExecuteCancel_descriptor;
  static final 
    com.google.protobuf.GeneratedMessageV3.FieldAccessorTable
      internal_static_worker_ExecuteCancel_fieldAccessorTable;
  static final com.google.protobuf.Descriptors.Descriptor
    internal_static_worker_ExecuteEvent_descriptor;
  static final 
    com.google.protobuf.GeneratedMessageV3.FieldAccessorTable
      internal_static_worker_ExecuteEvent_fieldAccessorTable;

  public static com.google.protobuf.Descriptors.FileDescriptor
      getDescriptor() {
    return descriptor;
  }
  private static  com.google.protobuf.Descriptors.FileDescriptor
      descriptor;
  static {
    java.lang.String[] descriptorData = {
      "\n\014worker.proto\022\006worker\"\227\001\n\016ExecuteComman" +
      "d\022\014\n\004argv\030\001 \003(\014\0224\n\003env\030\002 \003(\0132\'.worker.Ex" +
      "ecuteCommand.EnvironmentEntry\022\021\n\ttimeout" +
      "_s\030\003 \001(\004\032.\n\020EnvironmentEntry\022\013\n\003key\030\001 \001(" +
      "\014\022\r\n\005value\030\002 \001(\014\"O\n\017ExecuteResponse\022\021\n\te" +
      "xit_code\030\001 \001(\005\022\016\n\006stderr\030\002 \001(\t\022\031\n\021timed_" +
      "out_after_s\030\003 \001(\004\"\017\n\rExecuteCancel\"j\n\014Ex" +
      "ecuteEvent\022)\n\007command\030\001 \001(\0132\026.worker.Exe" +
      "cuteCommandH\000\022\'\n\006cancel\030\002 \001(\0132\025.worker.E" +
      "xecuteCancelH\000B\006\n\004data2\201\001\n\006Worker\022<\n\007Exe" +
      "cute\022\026.worker.ExecuteCommand\032\027.worker.Ex" +
      "ecuteResponse\"\000\0229\n\004Exec\022\024.worker.Execute" +
      "Event\032\027.worker.ExecuteResponse\"\000(\001B/\n\036co" +
      "m.facebook.buck.worker.modelB\013WorkerProt" +
      "oP\001b\006proto3"
    };
    com.google.protobuf.Descriptors.FileDescriptor.InternalDescriptorAssigner assigner =
        new com.google.protobuf.Descriptors.FileDescriptor.    InternalDescriptorAssigner() {
          public com.google.protobuf.ExtensionRegistry assignDescriptors(
              com.google.protobuf.Descriptors.FileDescriptor root) {
            descriptor = root;
            return null;
          }
        };
    com.google.protobuf.Descriptors.FileDescriptor
      .internalBuildGeneratedFileFrom(descriptorData,
        new com.google.protobuf.Descriptors.FileDescriptor[] {
        }, assigner);
    internal_static_worker_ExecuteCommand_descriptor =
      getDescriptor().getMessageTypes().get(0);
    internal_static_worker_ExecuteCommand_fieldAccessorTable = new
      com.google.protobuf.GeneratedMessageV3.FieldAccessorTable(
        internal_static_worker_ExecuteCommand_descriptor,
        new java.lang.String[] { "Argv", "Env", "TimeoutS", });
    internal_static_worker_ExecuteCommand_EnvironmentEntry_descriptor =
      internal_static_worker_ExecuteCommand_descriptor.getNestedTypes().get(0);
    internal_static_worker_ExecuteCommand_EnvironmentEntry_fieldAccessorTable = new
      com.google.protobuf.GeneratedMessageV3.FieldAccessorTable(
        internal_static_worker_ExecuteCommand_EnvironmentEntry_descriptor,
        new java.lang.String[] { "Key", "Value", });
    internal_static_worker_ExecuteResponse_descriptor =
      getDescriptor().getMessageTypes().get(1);
    internal_static_worker_ExecuteResponse_fieldAccessorTable = new
      com.google.protobuf.GeneratedMessageV3.FieldAccessorTable(
        internal_static_worker_ExecuteResponse_descriptor,
        new java.lang.String[] { "ExitCode", "Stderr", "TimedOutAfterS", });
    internal_static_worker_ExecuteCancel_descriptor =
      getDescriptor().getMessageTypes().get(2);
    internal_static_worker_ExecuteCancel_fieldAccessorTable = new
      com.google.protobuf.GeneratedMessageV3.FieldAccessorTable(
        internal_static_worker_ExecuteCancel_descriptor,
        new java.lang.String[] { });
    internal_static_worker_ExecuteEvent_descriptor =
      getDescriptor().getMessageTypes().get(3);
    internal_static_worker_ExecuteEvent_fieldAccessorTable = new
      com.google.protobuf.GeneratedMessageV3.FieldAccessorTable(
        internal_static_worker_ExecuteEvent_descriptor,
        new java.lang.String[] { "Command", "Cancel", "Data", });
  }

  // @@protoc_insertion_point(outer_class_scope)
}
