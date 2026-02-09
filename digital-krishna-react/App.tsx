
import React, { useState, useEffect, useRef, useMemo } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Message, Verse } from './types';
import { findRelevantVerses } from './services/gitaSearchService';
import { getKrishnaResponse } from './services/geminiService';
import { generateKrishnaVoice } from './services/ttsService';
import { GITA_VERSES } from './data/gita_data';

// --- Assets Configuration ---
const ASSETS = {
  LOGO: {
    local: 'assets/app_logo.png',
    remote: 'https://images.unsplash.com/photo-1542332213-31f87348057f?q=80&w=400&h=400&auto=format&fit=crop'
  },
  KRISHNA: {
    local: 'assets/krishna_avatar.png',
    remote: 'https://images.unsplash.com/photo-1617651139622-371631c7611a?q=80&w=400&h=400&auto=format&fit=crop'
  },
  USER: {
    local: 'assets/user_avatar.png',
    remote: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=400&h=400&auto=format&fit=crop'
  }
};

const CircleImage = ({ asset, className, sizeClass = "w-10 h-10", type = "avatar" }: { asset: {local: string, remote: string}; className?: string; sizeClass?: string; type?: "avatar" | "logo" }) => {
  const [imgSrc, setImgSrc] = useState(asset.local);
  const [retryCount, setRetryCount] = useState(0);
  const [isFinalFallback, setIsFinalFallback] = useState(false);

  const isKrishna = asset.local.includes('krishna') || asset.local.includes('logo');

  const handleError = () => {
    if (retryCount === 0) {
      setImgSrc(asset.remote);
      setRetryCount(1);
    } else {
      setIsFinalFallback(true);
    }
  };

  return (
    <div className={`rounded-full overflow-hidden border-2 border-white/30 shadow-lg flex-shrink-0 flex items-center justify-center ${sizeClass} ${className || ''} bg-[#1a1212] relative divine-glow`}>
      <div className={`absolute inset-0 bg-gradient-to-tr ${isKrishna ? 'from-[#C2185B] to-[#4A148C]' : 'from-[#455A64] to-[#263238]'} opacity-30`} />
      
      {isFinalFallback ? (
        <div className="relative z-10 flex flex-col items-center justify-center w-full h-full">
          <span className="text-white font-black text-lg drop-shadow-md">{isKrishna ? "ॐ" : "U"}</span>
        </div>
      ) : (
        <img 
          src={imgSrc} 
          alt="Divine Icon" 
          className="w-full h-full object-cover relative z-20"
          onError={handleError}
        />
      )}
    </div>
  );
};

const ChatHeader = ({ onBack, isMuted, onToggleMute }: { onBack: () => void; isMuted: boolean; onToggleMute: () => void }) => (
  <nav className="w-full px-4 py-3 flex items-center justify-between bg-black/90 z-[120] backdrop-blur-xl border-b border-white/10 safe-area-inset-top">
    <div className="flex items-center space-x-3">
      <button onClick={onBack} className="active:scale-90 transition-transform flex items-center p-1">
        <svg className="w-6 h-6 text-white/70" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M15 19l-7-7 7-7" />
        </svg>
        <CircleImage asset={ASSETS.KRISHNA} sizeClass="w-9 h-9 ml-1" />
      </button>
      <div className="flex flex-col">
        <h1 className="text-white text-base font-black tracking-tight leading-tight">Digital Krishna</h1>
        <span className="text-[7px] text-[#C2185B] font-black uppercase tracking-widest opacity-90">Universal Wisdom</span>
      </div>
    </div>
    <button 
      onClick={onToggleMute} 
      className={`w-9 h-9 flex items-center justify-center rounded-full transition-all border shadow-sm active:scale-90 ${!isMuted ? 'bg-[#C2185B] border-[#C2185B] text-white' : 'bg-white/10 border-white/20 text-white/50'}`}
    >
      {isMuted ? (
        <svg className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5.586 15H4a1 1 0 01-1-1v-4a1 1 0 011-1h1.586l4.707-4.707C10.923 3.663 12 4.109 12 5v14c0 .891-1.077 1.337-1.707.707L5.586 15z" />
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2" />
        </svg>
      ) : (
        <svg className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15.536 8.464a5 5 0 010 7.072m2.828-9.9a9 9 0 010 12.728M5.586 15H4a1 1 0 01-1-1v-4a1 1 0 011-1h1.586l4.707-4.707C10.923 3.663 12 4.109 12 5v14c0 .891-1.077 1.337-1.707.707L5.586 15z" />
        </svg>
      )}
    </button>
  </nav>
);

const ShlokaOfTheDay = () => {
  const dailyVerse = useMemo(() => {
    const today = new Date();
    const index = (today.getFullYear() + today.getMonth() + today.getDate()) % GITA_VERSES.length;
    return GITA_VERSES[index];
  }, []);

  return (
    <motion.div 
      initial={{ opacity: 0, y: 15 }}
      animate={{ opacity: 1, y: 0 }}
      className="w-full max-w-sm px-6 py-5 rounded-[2rem] border border-white/15 bg-black/70 backdrop-blur-3xl shadow-xl text-center mb-6 relative hide-on-keyboard"
    >
      <div className="absolute -top-2.5 left-1/2 -translate-x-1/2 px-4 py-1 bg-[#C2185B] rounded-full shadow-lg z-10">
        <span className="text-[8px] font-black uppercase tracking-widest text-white whitespace-nowrap">Daily Wisdom</span>
      </div>
      <p className="shloka-text mukta text-xl md:text-2xl text-white font-bold mb-3 mt-2 leading-snug">
        {dailyVerse.text}
      </p>
      <p className="shloka-translation text-white/70 text-sm italic mukta mb-4 px-2 leading-relaxed font-light line-clamp-3">
        "{dailyVerse.translation}"
      </p>
      <div className="inline-block px-4 py-1 bg-white/5 border border-[#C2185B]/40 rounded-full">
        <span className="text-[9px] font-black text-[#C2185B] uppercase tracking-wider">GITA {dailyVerse.chapter}.{dailyVerse.verse}</span>
      </div>
    </motion.div>
  );
};

const ShlokaCard: React.FC<{ verse: Verse }> = ({ verse }) => {
  const [isOpen, setIsOpen] = useState(false);
  const [copied, setCopied] = useState(false);

  const handleCopy = (e: React.MouseEvent) => {
    e.stopPropagation();
    const textToCopy = `Gita ${verse.chapter}.${verse.verse}\n\n${verse.text}\n\nTranslation: ${verse.translation}`;
    navigator.clipboard.writeText(textToCopy);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="mt-3 border border-[#C2185B]/30 rounded-2xl overflow-hidden bg-white/5 active:bg-white/10">
      <button 
        onClick={() => setIsOpen(!isOpen)}
        className="w-full flex items-center justify-between px-4 py-3 text-left"
      >
        <div className="flex items-center space-x-2">
          <div className="w-2 h-2 rounded-full bg-[#C2185B]" />
          <span className="text-[10px] font-black text-white uppercase tracking-tight">Gita {verse.chapter}.{verse.verse}</span>
        </div>
        <motion.div animate={{ rotate: isOpen ? 180 : 0 }} className="text-white/40">
          <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M19 9l-7 7-7-7" />
          </svg>
        </motion.div>
      </button>

      <AnimatePresence>
        {isOpen && (
          <motion.div
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: 'auto', opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            className="overflow-hidden bg-black/30"
          >
            <div className="p-4 pt-1 space-y-3">
              <p className="mukta text-lg text-white font-medium leading-relaxed border-l-2 border-[#C2185B] pl-3">
                {verse.text}
              </p>
              <p className="text-white/70 text-xs italic mukta leading-relaxed pl-4">
                {verse.translation}
              </p>
              <div className="flex justify-end pt-1">
                <button 
                  onClick={handleCopy}
                  className={`px-4 py-1.5 rounded-full text-[8px] font-black uppercase tracking-wider border ${copied ? 'bg-[#C2185B] border-[#C2185B] text-white' : 'text-white border-white/20'}`}
                >
                  {copied ? "Copied" : "Share"}
                </button>
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
};

const ChatBubble: React.FC<{ 
  message: Message; 
  onSpeak?: (text: string) => void;
  isSpeaking?: boolean;
}> = ({ message, onSpeak, isSpeaking }) => {
  const isKrishna = message.role === 'krishna';
  const timeStr = new Date(message.timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: false });
  
  return (
    <motion.div
      initial={{ opacity: 0, x: isKrishna ? -10 : 10 }}
      animate={{ opacity: 1, x: 0 }}
      className={`flex ${isKrishna ? 'justify-start' : 'justify-end'} mb-6 w-full items-end space-x-2`}
    >
      {isKrishna && <CircleImage asset={ASSETS.KRISHNA} sizeClass="w-9 h-9" className="mb-1" />}
      
      <div className={`relative px-5 py-4 max-w-[88%] rounded-2xl glass-panel shadow-md ${isKrishna ? 'rounded-bl-none border-l-2 border-l-[#C2185B]' : 'rounded-br-none border-r-2 border-r-white/20'}`}>
        <div className="flex justify-between items-start mb-1.5">
          {isKrishna && <span className="text-[9px] font-black text-[#C2185B] uppercase tracking-wider">Supreme Soul</span>}
          {onSpeak && isKrishna && (
             <button 
              onClick={() => onSpeak(message.text)}
              className={`transition-all p-1.5 rounded-full border active:scale-75 ${isSpeaking ? 'bg-[#C2185B] border-[#C2185B] text-white animate-pulse' : 'bg-white/5 border-white/10 text-white/50'}`}
             >
               <svg className="h-4 w-4" fill="currentColor" viewBox="0 0 20 20">
                 <path d="M9.383 3.076A1 1 0 0110 4v12a1 1 0 01-1.707.707L4.586 13H2a1 1 0 01-1-1V8a1 1 0 011-1h2.586l3.707-3.707a1 1 0 011.09-.217zM14.657 2.929a1 1 0 011.414 0A9.972 9.972 0 0119 10a9.972 9.972 0 01-2.929 7.071 1 1 0 01-1.414-1.414A7.971 7.971 0 0017 10c0-2.21-.894-4.208-2.343-5.657a1 1 0 010-1.414zm-2.829 2.828a1 1 0 011.415 0A5.983 5.983 0 0115 10a5.983 5.983 0 01-1.414 4.243 1 1 0 11-1.415-1.415A3.984 3.984 0 0013 10a3.984 3.984 0 00-1.414-2.829 1 1 0 010-1.415z" />
               </svg>
             </button>
          )}
        </div>

        <p className="chat-bubble-text text-white text-[15px] md:text-base mukta leading-relaxed whitespace-pre-wrap">
          {message.text}
        </p>

        {isKrishna && message.verses && message.verses.length > 0 && (
          <div className="mt-3 space-y-2">
            {message.verses.map((v: Verse, idx: number) => <ShlokaCard key={`${message.id}-v-${idx}`} verse={v} />)}
          </div>
        )}

        <div className="flex justify-end mt-1.5 opacity-30">
          <span className="text-[8px] font-mono">{timeStr}</span>
        </div>
      </div>

      {!isKrishna && <CircleImage asset={ASSETS.USER} sizeClass="w-9 h-9" className="mb-1" />}
    </motion.div>
  );
};

const Dashboard: React.FC<{ onStartChat: (prompt?: string) => void }> = ({ onStartChat }) => {
  return (
    <div className="flex-1 w-full flex flex-col items-center justify-center p-6 z-20">
      <ShlokaOfTheDay />

      <div className="flex flex-col items-center text-center w-full max-w-xs">
        <motion.div 
          initial={{ scale: 0.95, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          className="mb-6 rounded-full border-2 border-[#C2185B]/20 overflow-hidden w-36 h-36 flex items-center justify-center relative shadow-lg"
        >
          <CircleImage asset={ASSETS.LOGO} sizeClass="w-full h-full" type="logo" className="border-none" />
        </motion.div>
        
        <h2 className="text-4xl font-black text-white mukta uppercase mb-1">
          Digital Krishna
        </h2>
        <div className="w-12 h-0.5 bg-[#C2185B] mb-6 rounded-full opacity-60" />
        <p className="text-white/50 text-[9px] font-black tracking-widest uppercase mb-10">
          Cosmic AI Messenger
        </p>
        
        <button 
          onClick={() => onStartChat()}
          className="btn-magenta w-full rounded-full py-4 text-white font-black uppercase tracking-widest text-base active:scale-95"
        >
          Begin Dialogue
        </button>
      </div>
    </div>
  );
};

const SplashScreen = () => (
  <motion.div 
    initial={{ opacity: 1 }}
    exit={{ opacity: 0 }}
    transition={{ duration: 0.8 }}
    className="fixed inset-0 z-[200] bg-[#0A0707] flex flex-col items-center justify-center p-10"
  >
    <motion.div 
      animate={{ scale: [1, 1.03, 1] }}
      transition={{ repeat: Infinity, duration: 3 }}
      className="w-40 h-40 rounded-full overflow-hidden border border-[#C2185B]/30 shadow-2xl mb-10"
    >
      <CircleImage asset={ASSETS.LOGO} sizeClass="w-full h-full" type="logo" />
    </motion.div>
    <h1 className="mukta text-5xl font-black text-white tracking-tight mb-2">Digital Krishna</h1>
    <div className="flex items-center space-x-3 opacity-30">
       <div className="h-[1px] w-8 bg-white" />
       <p className="text-white text-[8px] font-black uppercase tracking-widest">Universal Wisdom</p>
       <div className="h-[1px] w-8 bg-white" />
    </div>
  </motion.div>
);

const App: React.FC = () => {
  const [showSplash, setShowSplash] = useState(true);
  const [view, setView] = useState<'dashboard' | 'chat'>('dashboard');
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [isMuted, setIsMuted] = useState(false);
  const [isListening, setIsListening] = useState(false);
  const [speakingText, setSpeakingText] = useState<string | null>(null);
  const [showScrollTop, setShowScrollTop] = useState(false);
  const [showScrollBottom, setShowScrollBottom] = useState(false);

  const scrollRef = useRef<HTMLDivElement>(null);
  const audioContextRef = useRef<AudioContext | null>(null);
  const recognitionRef = useRef<any>(null);

  useEffect(() => {
    const timer = setTimeout(() => setShowSplash(false), 2500);
    return () => clearTimeout(timer);
  }, []);

  const scrollToBottom = () => {
    if (scrollRef.current) {
      const { scrollHeight, clientHeight } = scrollRef.current;
      const maxScrollTop = scrollHeight - clientHeight;
      scrollRef.current.scrollTo({
        top: maxScrollTop > 0 ? maxScrollTop : 0,
        behavior: 'smooth'
      });
    }
  };

  const scrollToTop = () => {
    if (scrollRef.current) {
      scrollRef.current.scrollTo({
        top: 0,
        behavior: 'smooth'
      });
    }
  };

  useEffect(() => {
    const handleScroll = () => {
      if (!scrollRef.current) return;
      const { scrollTop, scrollHeight, clientHeight } = scrollRef.current;
      
      // Show top button if we have scrolled down at all
      setShowScrollTop(scrollTop > 10);
      
      // Show bottom button if we are not at the very bottom
      const isAtBottom = Math.abs(scrollHeight - clientHeight - scrollTop) < 10;
      // Only show bottom button if content is actually scrollable and we aren't at bottom
      const isScrollable = scrollHeight > clientHeight;
      setShowScrollBottom(isScrollable && !isAtBottom);
    };

    const ref = scrollRef.current;
    if (ref) {
      ref.addEventListener('scroll', handleScroll);
      // Also update on resize or mutations if possible, but scroll event covers scrolling.
      // Call once to set initial state
      handleScroll();
    }
    return () => ref?.removeEventListener('scroll', handleScroll);
  }, [messages]); // Re-check when messages change (content grows)

  useEffect(() => {
    // Scroll to bottom when messages change
    const timeoutId = setTimeout(scrollToBottom, 100);
    return () => clearTimeout(timeoutId);
  }, [messages, isLoading]);

  useEffect(() => {
    // Handle keyboard open/close on mobile
    const handleResize = () => {
      // Small delay to allow layout to adjust
      setTimeout(scrollToBottom, 100);
    };
    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  const handleSend = async (override?: string) => {
    const text = override || input;
    if (!text.trim() || isLoading) return;

    setMessages(prev => [...prev, { id: Date.now().toString(), role: 'user', text, timestamp: Date.now() }]);
    setInput('');
    setIsLoading(true);

    try {
      const relevant = findRelevantVerses(text);
      const res = await getKrishnaResponse(text, relevant, false);
      setMessages(prev => [...prev, { id: (Date.now()+1).toString(), role: 'krishna', text: res, timestamp: Date.now(), verses: relevant }]);
      if (!isMuted) handleSpeak(res);
    } catch (e) {
      setMessages(prev => [...prev, { id: 'err', role: 'krishna', text: "The divine flow is temporarily paused, Arjun. Ask again.", timestamp: Date.now() }]);
    } finally {
      setIsLoading(false);
    }
  };

  const initAudio = () => {
    if (!audioContextRef.current) {
      audioContextRef.current = new (window.AudioContext || (window as any).webkitAudioContext)();
    }
    if (audioContextRef.current.state === 'suspended') audioContextRef.current.resume();
  };

  const handleSpeak = async (text: string) => {
    initAudio();
    if (!audioContextRef.current) return;
    setSpeakingText(text);
    const buffer = await generateKrishnaVoice(text, audioContextRef.current);
    if (buffer && audioContextRef.current) {
      const source = audioContextRef.current.createBufferSource();
      source.buffer = buffer;
      source.connect(audioContextRef.current.destination);
      source.onended = () => setSpeakingText(null);
      source.start();
    } else {
      setSpeakingText(null);
    }
  };

  useEffect(() => {
    const SpeechRecognition = (window as any).SpeechRecognition || (window as any).webkitSpeechRecognition;
    if (SpeechRecognition) {
      recognitionRef.current = new SpeechRecognition();
      recognitionRef.current.lang = 'en-IN';
      recognitionRef.current.onstart = () => setIsListening(true);
      recognitionRef.current.onend = () => setIsListening(false);
      recognitionRef.current.onresult = (e: any) => {
        const transcript = e.results[0][0].transcript;
        if (transcript) handleSend(transcript);
      };
    }
  }, []);

  return (
    <div className="h-[100dvh] w-full flex flex-col relative overflow-hidden bg-[#0A0707] safe-area-inset-bottom">
      <AnimatePresence>{showSplash && <SplashScreen key="splash" />}</AnimatePresence>

      <AnimatePresence mode="wait">
        {!showSplash && (
          <motion.div key="main" initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="flex-1 w-full flex flex-col">
            {view === 'dashboard' ? (
              <Dashboard onStartChat={() => setView('chat')} />
            ) : (
              <div className="flex-1 flex flex-col h-full relative">
                <ChatHeader onBack={() => setView('dashboard')} isMuted={isMuted} onToggleMute={() => setIsMuted(!isMuted)} />

                <main ref={scrollRef} className="flex-1 overflow-y-auto px-4 pt-4 pb-32 z-10 touch-pan-y no-scrollbar overscroll-contain">
                  <div className="max-w-xl mx-auto flex flex-col">
                    {messages.length === 0 && (
                      <div className="text-center py-32 opacity-15 mukta text-2xl italic text-white/80 px-4">
                        "Fear not, for I am with thee."
                      </div>
                    )}
                    {messages.map(m => (
                      <ChatBubble 
                        key={m.id} 
                        message={m} 
                        onSpeak={m.role === 'krishna' ? handleSpeak : undefined} 
                        isSpeaking={speakingText === m.text} 
                      />
                    ))}
                    {isLoading && (
                      <div className="flex justify-start items-center space-x-2 mb-6">
                        <div className="w-8 h-8 rounded-full bg-white/5 animate-pulse" />
                        <div className="h-10 w-20 glass-panel rounded-full animate-pulse flex items-center justify-center space-x-1.5">
                          <div className="w-1 h-1 bg-[#C2185B] rounded-full animate-bounce" />
                          <div className="w-1 h-1 bg-[#C2185B] rounded-full animate-bounce [animation-delay:0.2s]" />
                          <div className="w-1 h-1 bg-[#C2185B] rounded-full animate-bounce [animation-delay:0.4s]" />
                        </div>
                      </div>
                    )}
                  </div>
                </main>

                {/* Scroll Buttons */}
                <div className="pointer-events-none fixed inset-0 z-[150]">
                  {/* Top Button */}
                  <button
                    onClick={scrollToTop}
                    className={`pointer-events-auto absolute top-24 right-4 w-10 h-10 bg-black/80 backdrop-blur-md border border-white/20 rounded-full flex items-center justify-center text-white shadow-xl transition-all duration-300 ${showScrollTop ? 'opacity-100 translate-y-0' : 'opacity-0 -translate-y-4 pointer-events-none'}`}
                  >
                    <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M5 10l7-7m0 0l7 7m-7-7v18" />
                    </svg>
                  </button>

                  {/* Bottom Button */}
                  <button
                    onClick={scrollToBottom}
                    className={`pointer-events-auto absolute bottom-28 right-4 w-10 h-10 bg-[#C2185B] border border-white/20 rounded-full flex items-center justify-center text-white shadow-xl transition-all duration-300 ${showScrollBottom ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-4 pointer-events-none'}`}
                  >
                    <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M19 14l-7 7m0 0l-7-7m7 7V3" />
                    </svg>
                  </button>
                </div>

                <footer className="fixed bottom-0 left-0 right-0 p-3 pb-4 z-[110] bg-gradient-to-t from-black via-black/90 to-transparent">
                  <div className="w-full max-w-lg mx-auto">
                    <div className="glass-panel w-full flex items-center rounded-full px-1.5 py-1 shadow-xl">
                      <button 
                        onClick={() => {
                          initAudio();
                          recognitionRef.current?.start();
                        }}
                        className={`w-9 h-9 flex items-center justify-center rounded-full transition-all active:scale-90 border ${isListening ? 'bg-[#C2185B] border-[#C2185B] text-white shadow-lg' : 'bg-white/5 border-white/10 text-white/50'}`}
                      >
                        <svg className="h-4 w-4" fill="currentColor" viewBox="0 0 20 20">
                          <path d="M7 4a3 3 0 016 0v4a3 3 0 11-6 0V4zm4 10.93A7.001 7.001 0 0017 8a1 1 0 10-2 0A5 5 0 015 8a1 1 0 00-2 0 7.001 7.001 0 006 6.93V17H6a1 1 0 100 2h8a1 1 0 100-2h-3v-2.07z" />
                        </svg>
                      </button>
                      
                      <input 
                        type="text" 
                        value={input} 
                        onChange={e => setInput(e.target.value)} 
                        onKeyDown={e => e.key === 'Enter' && handleSend()} 
                        placeholder={isListening ? "Listening..." : "Thy dialogue..."}
                        className="bg-transparent border-none outline-none text-white flex-1 px-3 py-1.5 text-sm mukta placeholder-white/15" 
                      />
                      
                      <button 
                        onClick={() => handleSend()} 
                        disabled={!input.trim()}
                        className={`w-9 h-9 flex items-center justify-center rounded-full transition-all active:scale-90 border ${input.trim() ? 'bg-[#C2185B] border-[#C2185B] text-white' : 'bg-white/5 border-white/10 text-white/5'}`}
                      >
                        <svg className="w-4 h-4 rotate-90" fill="currentColor" viewBox="0 0 20 20">
                          <path d="M10.894 2.553a1 1 0 00-1.788 0l-7 14a1 1 0 001.169 1.409l5-1.429A1 1 0 009 15.571V11a1 1 0 112 0v4.571a1 1 0 00.725.962l5 1.428a1 1 0 001.17-1.408l-7-14z" />
                        </svg>
                      </button>
                    </div>
                  </div>
                </footer>
              </div>
            )}
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
};

export default App;
