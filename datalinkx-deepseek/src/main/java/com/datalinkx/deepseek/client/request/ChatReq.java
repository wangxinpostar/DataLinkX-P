package com.datalinkx.deepseek.client.request;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class ChatReq {
    private String model;
    private Integer maxTokens=8192;
    private List<Content> messages;
    private Double temperature;
    private Boolean stream;

    @Data
    @Builder
    @AllArgsConstructor
    @NoArgsConstructor
    public static final class Content {
        private String role;
        private String content;
    }
}
