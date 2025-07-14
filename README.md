# 🎵 Ari - 블록체인 기반 음원 스트리밍 플랫폼

<p align="center">
  <img width="1728" height="1117" alt="readme_img" src="https://github.com/user-attachments/assets/78ee0036-d2c2-4d4a-a347-25962c21dbb6" />
</p>

불투명한 정산과 복잡한 음원 등록 과정을 개선하기 위한 탈중앙화 음원 플랫폼입니다.  
투명한 스트리밍 데이터와 자동화된 정산 시스템으로 아티스트와 사용자 모두에게 공정한 생태계를 제공합니다.

---

## 📚 목차 (Table of Contents)
- [🧭 프로젝트 소개](#-프로젝트-소개)
- [🧩 문제 정의](#-문제-정의)
- [💡 해결방안](#-해결방안)
- [🔧 기술 구성](#-기술-구성)
  - [📦 아키텍처 요약](#-아키텍처-요약)
  - [🖼️ 와이어프레임](#-와이어프레임)
  - [📊 ERD](#-erd)
  - [🧱 주요 기술 스택](#-주요-기술-스택)
- [⚙️ 성능 개선 및 기술 고도화](#️-성능-개선-및-기술-고도화)
- [👥 팀 구성](#-팀-구성)

---

## 🧭 프로젝트 소개

- **기간**: (예: 2025.03.04 ~ 2025.04.11)
- **기획의도**:  
  기존 음원 플랫폼의 불투명한 정산과 복잡한 등록 과정을 개선하고, 블록체인 기술로 공정한 생태계를 구축하기 위함
- **핵심 컨셉**:  
  블록체인 기반으로 투명한 데이터 관리, 자동화된 정산, 누구나 쉽게 음원을 등록할 수 있는 플랫폼 제공

---

## 🧩 문제 정의

기존 음원 플랫폼은 다음과 같은 문제를 안고 있습니다:

- ❌ 불투명한 스트리밍 데이터  
- ❌ 불공정한 수익 정산 구조  
- ❌ 복잡하고 제한적인 음원 등록 과정  
- ❌ 불법 사재기 및 조회수 조작 문제  

---

## 💡 해결방안

Ari는 블록체인의 **투명성, 불변성, 탈중앙화** 특성을 활용하여 아래와 같은 기능을 구현합니다.

| 기능 | 설명 |
|------|------|
| 🔎 투명한 스트리밍 데이터 | IPFS + Merkle Tree를 통한 검증 가능한 데이터 |
| 💰 공정한 정산 시스템 | 스마트 컨트랙트를 활용한 온체인 정산 |
| 🚀 간편한 음원 등록 | 누구나 몇 번의 클릭으로 음원 등록 가능 |
| 🔄 자동화된 정산 | Chainlink Automation을 통한 구독 기반 정산 자동화 |

---

## 🔧 기술 구성

### 📦 아키텍처 요약

![BE아키텍처 drawio](https://github.com/user-attachments/assets/55ddf8f3-e5d6-4951-9b94-b41a7569e297)

---

### 🖼️ 와이어프레임

[![와이어프레임 이미지](https://github.com/user-attachments/assets/1d165683-195c-459b-84eb-9b1f4ed0e55e)](https://www.figma.com/design/u3TaYpFQBUJqVA4AGsqAUd/C205?node-id=0-1&t=q8F4l43WPhIjrrS0-1)

---

### 📊 ERD

![특화 (1)](https://github.com/user-attachments/assets/c35bea2d-b8cd-44e2-b1cd-561a1da41b41)

---

### 🧱 주요 기술 스택

### 🖥️ Client
<img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white"/> <img src="https://img.shields.io/badge/Hive-FF8C00?style=for-the-badge&logo=hive&logoColor=white"/> <img src="https://img.shields.io/badge/just_audio-4CAF50?style=for-the-badge&logo=musicbrainz&logoColor=white"/>

### 🛠 Backend
<img src="https://img.shields.io/badge/SpringBoot-6DB33F?style=for-the-badge&logo=springboot&logoColor=white"/> <img src="https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white"/> <img src="https://img.shields.io/badge/MongoDB-47A248?style=for-the-badge&logo=mongodb&logoColor=white"/> <img src="https://img.shields.io/badge/Redis-DC382D?style=for-the-badge&logo=redis&logoColor=white"/>

### ⚙ Infra & 기타
<img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white"/> <img src="https://img.shields.io/badge/Nginx-009639?style=for-the-badge&logo=nginx&logoColor=white"/> <img src="https://img.shields.io/badge/Jenkins-D24939?style=for-the-badge&logo=jenkins&logoColor=white"/> <img src="https://img.shields.io/badge/IPFS-65C2CB?style=for-the-badge&logo=ipfs&logoColor=white"/> <img src="https://img.shields.io/badge/Chainlink-375BD2?style=for-the-badge&logo=chainlink&logoColor=white"/> <img src="https://img.shields.io/badge/MerkleTree-8A2BE2?style=for-the-badge&logo=tree&logoColor=white"/>



---

## ⚙️ 성능 개선 및 기술 고도화

- 기존 스트리밍 내역 조회 시간: 평균 **46초**  
- 개선 후 핀닝 + 비동기 처리: 평균 **8초**  
  → `CompletableFuture` 구조 도입으로 응답 속도 대폭 개선


---

## 👥 팀 구성

### 🎧 캐릭캐릭체인 팀

<table>
  <tbody>
    <tr align="center">
      <td><img src="https://avatars.githubusercontent.com/u/113484236?v=4" width="100px;" style="border-radius: 50%;" alt=""/><br /></td>
      <td><img src="https://avatars.githubusercontent.com/u/108385400?v=4" width="100px;" style="border-radius: 50%;" alt=""/><br /></td>
      <td><img src="https://avatars.githubusercontent.com/u/174885052?v=4" width="100px;" style="border-radius: 50%;" alt=""/><br /></td>
      <td><img src="https://avatars.githubusercontent.com/u/175234691?v=4" width="100px;" style="border-radius: 50%;" alt=""/><br /></td>
      <td><img src="https://avatars.githubusercontent.com/u/145769307?v=4" width="100px;" style="border-radius: 50%;" alt=""/><br /></td>
      <td><img src="https://avatars.githubusercontent.com/u/101163507?v=4" width="100px;" style="border-radius: 50%;" alt=""/><br /></td>
    </tr>
    <tr align="center">
      <td width="200"><a href="http://github.com/miltonjskim">팀장 : 김준석<br/>INFJ</a></td>
      <td width="200"><a href="http://github.com/wjdrbgus8167">팀원 : 정규현<br/>ISFP</a></td>
      <td width="200"><a href="https://github.com/kingkang85">팀원 : 강지민<br/>ISTP</a></td>
      <td width="200"><a href="https://github.com/naemhui">팀원 : 권남희<br/>ENFP</a></td>
      <td width="200"><a href="https://github.com/songowen">팀원 : 송창현<br/>ISTP</a></td>
      <td width="200"><a href="https://github.com/jinwooseok">팀원 : 진우석<br/>ENTJ</a></td>
    </tr>
    <tr align="center" height="200">
      <td>온체인 정산 설계 및 구현<br>Redis, IPFS, 스마트컨트랙트<br>Chainlink 오토메이션</td>
      <td>시각화 / 디자인 구조 설계<br>정산 시각 자료 구성</td>
      <td>블록체인 인프라 구성<br>IPFS 데이터 구조 및 처리<br>CID, Merkle Tree 저장</td>
      <td>프론트엔드 메인페이지, 트랙 재생 관련 파트<br>인프라 담당</td>
      <td>프론트엔드 전체 구조 설계<br>IPFS 스트리밍 내역 처리<br>React 기반 구현</td>
      <td>프론트엔드 문서 작성<br>페이지 구성 정리 및 README</td>
    </tr>
  </tbody>
</table>
